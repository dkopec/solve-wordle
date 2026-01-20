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
DATA_DIR = Path("wwwroot/data")
BACKUP_DIR = Path("wwwroot/data/backups")

# Data sources
WORDLE_ANSWERS_URL = "https://www.nytimes.com/games-assets/v2/wordle.json"
WORDLE_JS_URL = "https://www.nytimes.com/games-assets/v2/wordle/{hash}/wordle.{hash}.js"
FALLBACK_SCRABBLE_URL = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
# Word frequency data (ranked by usage frequency in American English)
WORD_FREQUENCY_URL = "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa.txt"

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
    
    def fetch_word_frequencies(self) -> dict[str, int]:
        """
        Fetch word frequency data from public sources.
        Returns dictionary mapping word -> rank (1 = most common).
        """
        self.log("Fetching word frequency data...")
        frequency_map = {}
        
        try:
            response = self.fetch_url(WORD_FREQUENCY_URL, timeout=15)
            if response:
                lines = response.text.strip().split('\n')
                for rank, word in enumerate(lines, start=1):
                    word = word.strip().lower()
                    if word and len(word) == 5 and word.isalpha():
                        frequency_map[word] = rank
                
                self.verbose_log(f"Loaded {len(frequency_map)} 5-letter word frequencies")
        except Exception as e:
            self.log(f"Warning: Could not fetch frequency data: {e}", "WARNING")
        
        return frequency_map
    
    def determine_common_words(self, all_words: Set[str], past_answers: Set[str]) -> List[str]:
        """
        Determine common words and sort by actual frequency.
        Uses word frequency data from linguistic corpora.
        The WordleSolver scoring algorithm depends on this order!
        """
        self.log("Determining common words...")
        
        # Fetch actual word frequency rankings
        frequency_map = self.fetch_word_frequencies()
        
        # Start with candidate words
        candidates = set()
        
        # Include past answers (proven good Wordle words)
        candidates.update(past_answers)
        
        # Include existing common words
        existing_file = DATA_DIR / "common-words.txt"
        if existing_file.exists():
            existing_common = existing_file.read_text(encoding='utf-8').strip().split('\n')
            for word in existing_common:
                word = word.strip().lower()
                if word and len(word) == 5 and word.isalpha():
                    candidates.add(word)
        
        # Filter to only include words in comprehensive list
        candidates = candidates.intersection(all_words)
        
        # Sort by actual frequency
        if frequency_map:
            self.log(f"Sorting {len(candidates)} words by frequency...")
            
            # Sort by frequency rank (lower rank = more common)
            # Words not in frequency map get high rank (appear at end)
            common_list = sorted(
                candidates,
                key=lambda w: (
                    frequency_map.get(w, 999999),  # Primary: frequency rank
                    w  # Secondary: alphabetical for consistency
                )
            )
        else:
            # Fallback: preserve existing order or use alphabetical
            self.log("Warning: Using fallback ordering (no frequency data)", "WARNING")
            if existing_file.exists():
                # Preserve existing order
                common_list = []
                seen = set()
                for word in existing_common:
                    word = word.strip().lower()
                    if word in candidates and word not in seen:
                        common_list.append(word)
                        seen.add(word)
                # Add remaining candidates
                for word in sorted(candidates - seen):
                    common_list.append(word)
            else:
                common_list = sorted(candidates)
        
        self.log(f"Determined {len(common_list)} common words (frequency-ordered)")
        return common_list
    
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
    
    def write_word_file(self, filepath: Path, words, description: str):
        """Write word list to file"""
        # For common-words.txt, preserve frequency order; for others, sort alphabetically
        if filepath.name == "common-words.txt":
            # Preserve frequency-based ordering (most common first)
            word_list = words if isinstance(words, list) else sorted(words)
        else:
            # Alphabetically sort other word lists
            word_list = sorted(words) if not isinstance(words, list) else sorted(words)
        
        content = '\n'.join(word_list)
        content = '\n'.join(word_list)
        
        # Check if content changed
        existing_content = ""
        if filepath.exists():
            existing_content = filepath.read_text(encoding='utf-8')
        
        if content != existing_content.strip():
            self.changes_made = True
            
            if self.dry_run:
                self.log(f"DRY RUN: Would update {filepath} ({len(word_list)} words)")
                self.log(f"  Current: {len(existing_content.split())} words")
                self.log(f"  New: {len(word_list)} words")
                return
            
            filepath.write_text(content, encoding='utf-8')
            self.log(f"✓ Updated {filepath.name}: {len(word_list)} {description}")
        else:
            self.log(f"✓ No changes for {filepath.name}")
    

    
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
