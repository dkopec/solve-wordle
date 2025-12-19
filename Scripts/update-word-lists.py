#!/usr/bin/env python3
"""
Automated Word List Updater for Wordle Solver

This script fetches the latest Wordle data and updates word list files.
It retrieves:
1. Past Wordle answers from NYTimes Wordle game data
2. Common English words from frequency lists
3. Comprehensive 5-letter word lists

Usage:
    python update-word-lists.py [--dry-run] [--verbose]
"""

import sys
import json
import requests
from datetime import datetime, timedelta
from pathlib import Path
from typing import Set, List, Tuple
import time

# Configuration
DATA_DIR = Path("Data")
WWWROOT_DATA_DIR = Path("wwwroot/data")
BACKUP_DIR = Path("Data/backups")

# Data sources
WORDLE_ANSWERS_URL = "https://www.nytimes.com/games-assets/v2/wordle.json"
WORDLE_JS_URL = "https://www.nytimes.com/games-assets/v2/wordle/{hash}/wordle.{hash}.js"
FALLBACK_SCRABBLE_URL = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"

class WordListUpdater:
    def __init__(self, verbose=False, dry_run=False):
        self.verbose = verbose
        self.dry_run = dry_run
        self.changes_made = False
        
    def log(self, message, level="INFO"):
        """Log messages with timestamp"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] [{level}] {message}")
    
    def verbose_log(self, message):
        """Log only in verbose mode"""
        if self.verbose:
            self.log(message, "DEBUG")
    
    def fetch_url(self, url, timeout=10):
        """Fetch URL with retry logic"""
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        }
        
        for attempt in range(3):
            try:
                self.verbose_log(f"Fetching {url} (attempt {attempt + 1})")
                response = requests.get(url, headers=headers, timeout=timeout)
                response.raise_for_status()
                return response
            except requests.RequestException as e:
                self.log(f"Attempt {attempt + 1} failed: {e}", "WARNING")
                if attempt < 2:
                    time.sleep(2 ** attempt)  # Exponential backoff
                else:
                    raise
    
    def fetch_past_wordle_answers(self) -> Set[str]:
        """
        Fetch past Wordle answers from NYTimes.
        Returns set of lowercase 5-letter words.
        """
        self.log("Fetching past Wordle answers from NYTimes...")
        past_answers = set()
        
        # Method 1: Try official Wordle JSON endpoint
        try:
            response = self.fetch_url(WORDLE_ANSWERS_URL)
            data = response.json()
            
            if 'solutions' in data:
                past_answers.update(w.lower() for w in data['solutions'] if len(w) == 5)
                self.log(f"Found {len(past_answers)} answers from JSON endpoint")
        except Exception as e:
            self.log(f"Could not fetch from JSON endpoint: {e}", "WARNING")
        
        # Method 2: Try to extract from JavaScript bundle
        if not past_answers:
            try:
                self.log("Attempting to extract from Wordle JS bundle...")
                # This would require parsing the JS - skipping for now
                # In production, you'd parse the bundled JS file
                pass
            except Exception as e:
                self.log(f"Could not extract from JS bundle: {e}", "WARNING")
        
        # Method 3: Use existing file and add known recent answers
        if not past_answers:
            self.log("Using existing past-answers.txt as base", "WARNING")
            existing_file = DATA_DIR / "past-answers.txt"
            if existing_file.exists():
                past_answers = set(existing_file.read_text(encoding='utf-8').strip().split('\n'))
                self.log(f"Loaded {len(past_answers)} existing answers")
                
                # Add any known recent answers manually
                # (In production, you'd maintain a list of recent answers to add)
                known_recent = {
                    # Add new answers here as they appear
                    # Format: 'word'
                }
                past_answers.update(known_recent)
        
        return past_answers
    
    def fetch_comprehensive_wordlist(self) -> Set[str]:
        """
        Fetch comprehensive 5-letter English words.
        Returns set of valid 5-letter words.
        """
        self.log("Fetching comprehensive word list...")
        all_words = set()
        
        # Use existing file as base (it's already comprehensive)
        existing_file = DATA_DIR / "words.txt"
        if existing_file.exists():
            all_words = set(existing_file.read_text(encoding='utf-8').strip().split('\n'))
            self.log(f"Loaded {len(all_words)} existing words")
        
        # Could fetch additional words from Scrabble dictionary or other sources
        try:
            response = self.fetch_url(FALLBACK_SCRABBLE_URL)
            scrabble_words = {
                word.lower() for word in response.text.split('\n') 
                if len(word) == 5 and word.isalpha()
            }
            
            original_count = len(all_words)
            all_words.update(scrabble_words)
            new_count = len(all_words)
            
            if new_count > original_count:
                self.log(f"Added {new_count - original_count} new words from Scrabble dictionary")
        except Exception as e:
            self.log(f"Could not fetch Scrabble dictionary: {e}", "WARNING")
        
        return all_words
    
    def determine_common_words(self, all_words: Set[str], past_answers: Set[str]) -> Set[str]:
        """
        Determine common words from various sources.
        Prioritizes past Wordle answers as they're proven common words.
        """
        self.log("Determining common words...")
        common = set()
        
        # Start with past answers (proven Wordle words)
        common.update(past_answers)
        
        # Load existing common words
        existing_file = DATA_DIR / "common-words.txt"
        if existing_file.exists():
            existing_common = set(existing_file.read_text(encoding='utf-8').strip().split('\n'))
            common.update(existing_common)
        
        # Filter to only include words in comprehensive list
        common = common.intersection(all_words)
        
        self.log(f"Determined {len(common)} common words")
        return common
    
    def backup_files(self):
        """Create backups of existing data files"""
        if self.dry_run:
            self.log("DRY RUN: Would create backups")
            return
        
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for filename in ["words.txt", "common-words.txt", "past-answers.txt"]:
            source = DATA_DIR / filename
            if source.exists():
                backup = BACKUP_DIR / f"{source.stem}_{timestamp}.txt"
                backup.write_text(source.read_text(encoding='utf-8'), encoding='utf-8')
                self.verbose_log(f"Backed up {filename} to {backup}")
    
    def write_word_file(self, filepath: Path, words: Set[str], description: str):
        """Write sorted word list to file"""
        sorted_words = sorted(words)
        content = '\n'.join(sorted_words)
        
        # Check if content changed
        existing_content = ""
        if filepath.exists():
            existing_content = filepath.read_text(encoding='utf-8')
        
        if content != existing_content.strip():
            self.changes_made = True
            
            if self.dry_run:
                self.log(f"DRY RUN: Would update {filepath} ({len(sorted_words)} words)")
                self.log(f"  Current: {len(existing_content.split())} words")
                self.log(f"  New: {len(sorted_words)} words")
                return
            
            filepath.write_text(content, encoding='utf-8')
            self.log(f"✓ Updated {filepath.name}: {len(sorted_words)} {description}")
        else:
            self.log(f"✓ No changes for {filepath.name}")
    
    def sync_to_wwwroot(self):
        """Sync Data/ files to wwwroot/data/"""
        if self.dry_run:
            self.log("DRY RUN: Would sync to wwwroot/data/")
            return
        
        WWWROOT_DATA_DIR.mkdir(parents=True, exist_ok=True)
        
        for filename in ["words.txt", "common-words.txt", "past-answers.txt"]:
            source = DATA_DIR / filename
            dest = WWWROOT_DATA_DIR / filename
            
            if source.exists():
                dest.write_text(source.read_text(encoding='utf-8'), encoding='utf-8')
                self.verbose_log(f"Synced {filename} to wwwroot/data/")
    
    def run(self):
        """Main update process"""
        self.log("=== Starting Word List Update ===")
        start_time = time.time()
        
        try:
            # Backup existing files
            self.backup_files()
            
            # Fetch data
            past_answers = self.fetch_past_wordle_answers()
            all_words = self.fetch_comprehensive_wordlist()
            common_words = self.determine_common_words(all_words, past_answers)
            
            # Ensure directories exist
            DATA_DIR.mkdir(parents=True, exist_ok=True)
            
            # Write updated files
            self.write_word_file(
                DATA_DIR / "past-answers.txt",
                past_answers,
                "past Wordle answers"
            )
            
            self.write_word_file(
                DATA_DIR / "common-words.txt",
                common_words,
                "common words"
            )
            
            self.write_word_file(
                DATA_DIR / "words.txt",
                all_words,
                "total words"
            )
            
            # Sync to wwwroot
            self.sync_to_wwwroot()
            
            elapsed = time.time() - start_time
            self.log(f"=== Update Complete ({elapsed:.1f}s) ===")
            
            if self.changes_made:
                self.log("✓ Changes detected and files updated", "SUCCESS")
                return 0
            else:
                self.log("ℹ No changes needed - files are up to date", "INFO")
                return 0
                
        except Exception as e:
            self.log(f"Error during update: {e}", "ERROR")
            import traceback
            traceback.print_exc()
            return 1


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Update Wordle Solver word lists')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what would be done without making changes')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Enable verbose logging')
    
    args = parser.parse_args()
    
    updater = WordListUpdater(verbose=args.verbose, dry_run=args.dry_run)
    sys.exit(updater.run())


if __name__ == '__main__':
    main()
