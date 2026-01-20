# Aggressive Wordle Scoring Strategies

## Overview
This solver uses multiple aggressive strategies to quickly identify the most likely Wordle answer.

## Scoring Factors (Highest to Lowest Weight)

### 1. **Word Commonality (Weight: 2.0x + multipliers up to 1.5x)** 🌟
- **Past Wordle answers that are also common words** (e.g., APPLE, STARE, AROSE): 1300 points + 1.5x multiplier = HIGHEST priority
  - These are the sweet spot: proven Wordle words that people use daily
- **Past Wordle answers (less common)** (e.g., AMPLE, AGORA, CYNIC): 1000 points + 1.5x multiplier
  - Proven Wordle words but less common in everyday speech
- **Common English words** (curated frequency list): 900-400 points + 1.3x multiplier
  - Words ranked by actual usage frequency in English
  - Includes everyday words like GRAVE, ABOUT, HEART, etc.
  - Excludes obscure/technical terms like BRANE, ZOEAE, etc.
- **Other valid words**: 0-100 points + penalties for very obscure words
- Prioritizes words people actually use and Wordle typically selects
- Three-tier system with bonus for common past answers

### 2. **Trigram Analysis (Weight: 4.0x)** 🔥
- Analyzes 3-letter sequences from past Wordle answers
- Real words have predictable letter combinations
- Example: "tion", "ing", "ent" are common trigrams

### 3. **Position-Specific Letter Frequency (Weight: 5.0x)** 🎯
- Each letter position (1-5) has different common letters
- 'S' is common at position 1, 'E' common at position 5
- Most accurate predictor of actual Wordle answers

### 4. **Bigram Analysis (Weight: 3.5x)** 📊
- Analyzes 2-letter pairs from past answers
- Helps identify natural word patterns
- Example: "th", "er", "on", "re" are common

### 5. **Common Ending Patterns (Bonus: +50-75)** 🎪
- Tracks frequent 2 and 3-letter endings from past answers
- Words ending in "er", "ed", "ly", "ng", etc. get bonuses
- Helps distinguish real words from random letter combos

### 6. **Overall Letter Frequency (Weight: 3.0x)** 📈
- Letters that appear frequently in past answers
- E, A, R, O, T, L, I, S are most common
- Weighted for unique letters in the word

### 7. **Vowel Distribution (Multiplier: 1.4x for 2 vowels)** 🎵
- Optimal: 1-3 vowels (most Wordle answers)
- Best: exactly 2 vowels (1.4x multiplier)
- Penalty: 0.4x for 0 or 4+ vowels

### 8. **Vowel Position Scoring (Weight: 0.5x)** 📍
- Certain vowels prefer certain positions
- Enhances positional accuracy

### 9. **Past Answer Pattern Match (Multiplier: 1.8x)** ⭐
- Strong bonus if word structure matches past answers
- Wordle reuses similar word patterns

### 10. **Common Starting Letters (Multiplier: 1.15x)** 🚀
- S, C, P, T, A, B, R, L, M, F are common starters
- Slight boost for words starting with these

### 11. **Duplicate Letter Priority** 🔁
- **5 unique letters** (0.8x penalty): All unique - no pattern matching benefit
- **4 unique letters** (1.4x multiplier): One repeated letter - very common in Wordle
  - Examples: BATTY, FIZZY, HAPPY, PUPPY, GRASS
  - Many Wordle answers have double letters
- **3 unique letters** (1.8x multiplier): Two repeated letters - strong pattern match
- **2 or fewer unique letters** (2.2x multiplier): Heavy repetition - highest bonus
  - Examples: EERIE, MAMMA, LLAMA, COCOA, PEEPS

## Why Word Commonality Matters Most

Wordle deliberately chooses **everyday words** that most people know. The solver now uses a **three-tier ranking system**:

1. **Past Wordle Answers (1000 points)**: Words that have been actual Wordle answers
   - Highest priority - proven Wordle words
   - Gets additional 1.5x multiplier

2. **Common English Words (900-400 points)**: Curated list of frequently-used words
   - Ranked by actual usage frequency in English
   - Includes: GRAVE, AROSE, STARE, ABOUT, HEART, PLACE, etc.
   - Gets 1.3x multiplier
   - This ensures common words like GRAVE beat obscure words like BRANE

3. **Rare/Technical Words (0-100 points)**: All other valid 5-letter words
   - Scientific terms, archaic words, obscure vocabulary
   - Examples: BRANE (physics term), ZOEAE (plural of zoea), AAHED (exclamation)
   - Heavy penalties (0.6x multiplier) for very obscure words

This ensures you'll see recognizable words like **AROSE**, **SLATE**, **CRANE**, **GRAVE** at the top instead of obscure words like **BRANE**, **ZOEAE**, or **XYSTI**, even if they have similar letter patterns.

## Confidence Calculation

### Aggressive Differentiation
- **1 word**: 98% confidence
- **2-3 words**: Top word gets 85-95% confidence
- **4-10 words**: Top word gets 70-85% confidence  
- **11-50 words**: Top word gets 50-70% confidence
- **50+ words**: Top word gets 40-60% confidence

### Exponential Curve (Power: 0.4)
- Heavily favors #1 over #2
- Creates clear separation between top choices
- Top word receives 1.15x additional boost

## Result Presentation

### Visual Indicators
- ⭐ **#1 ranked** words highlighted with star icon
- 🎯 **75%+ confidence** marked as "BEST"
- 🟢 **Green badges**: 70%+ confidence
- 🔵 **Blue badges**: 50-70% confidence
- 🟡 **Yellow badges**: 30-50% confidence
- ⚫ **Gray badges**: <30% confidence

### Status Badges
- **"CLOSE!"** - 5 or fewer words remaining
- **"NARROWING"** - 6-20 words remaining
- **Strong recommendation** shown when top word has 75%+ confidence

### Progress Tracking
- Total suggestion count prominently displayed
- Top 50 words shown (ranked best to worst)
- Animated progress bar for #1 suggestion

## Goal
Get to the answer as quickly as possible by:
1. Analyzing multiple word characteristics simultaneously
2. Heavily weighting proven patterns from past Wordle answers
3. Providing clear visual guidance on which word to try next
4. Showing confidence levels to help decision-making
5. **Suggesting strategic "throwaway words" to eliminate possibilities faster**

## Strategic Throwaway Words 🎯

### When to Use Them
When there are **6+ possible words remaining**, the solver suggests "throwaway words" - strategic guesses that maximize information gain even though they're unlikely to be the answer.

### How They Work
Strategic words are selected based on:

1. **NO Green Letters Rule** ❌🟢
   - **CRITICAL**: Strategic words NEVER contain letters you already know (green)
   - Those letters are confirmed - no need to test them again
   - Focuses testing on UNCERTAIN letters only
   - Maximizes new information per guess

2. **Optimal Split Analysis (40-60% coverage = 15x multiplier)**
   - Identifies letters appearing in 40-60% of remaining possibilities
   - Creates perfect "elimination splits" - each result rules out ~half the words
   - Example: If letter 'R' is in 50% of possibilities, testing it splits the list in half
   - 30-40% or 60-75% coverage also valuable (12x multiplier)

3. **Duplicate Letter Preference (2.5x multiplier)**
   - **CHANGED from unique letter maximization**
   - Now prioritizes words with repeated letters
   - Helps identify patterns and common word structures
   - 4 unique letters (one repeated) = 1.5x multiplier
   - 3 or fewer unique letters = 2.5x multiplier

4. **Position-Specific Testing**
   - Tests letters in positions where they commonly appear in remaining words
   - Helps narrow down exact letter positions quickly
   - Ignores positions with confirmed green letters

5. **Common Letter Coverage**
   - Includes letters like E, A, R, O, T, L, I, S, N, C
   - Broad coverage across English vocabulary
   - But ONLY if they're not already green

6. **Penalty for Obscure Words**
   - Still want recognizable words (1.2x boost if commonality > 300)
   - Heavy penalty (0.5x) for very rare words
   - Strategic words should be easy to type and spell!

### Strategy Example
**Scenario: You know the answer has 'A' in position 2 (green)**

- ❌ **OLD behavior**: Might suggest "SLATE" or "CRATE" (wasting the known 'A')
- ✅ **NEW behavior**: Suggests "MOIST" or "CHUNK" (tests NEW letters, avoids 'A')
- **Result**: Each letter in the strategic word gives you NEW information

**Full Example:**
- **100 possibilities, A_E__ pattern**: Use throwaway word like "MOIST" (no A or E)
- After results: Might reduce to 10-15 possibilities
- **10 possibilities, remaining**: Use throwaway word like "CHUNK"
- After results: Might reduce to 1-3 possibilities
- **1-5 possibilities**: Go directly for the answer (no throwaway needed)

### Benefits
- **Faster solving**: Reduce 50+ words to <10 in one guess
- **Information maximization**: Test the most uncertain variables
- **Strategic depth**: Play like an expert Wordle solver
- **Confidence building**: Narrow options before committing to answer

### Visual Indicators
- 💡 **Yellow warning box** appears when 6+ possibilities remain
- ⚙️ **Gear icon badges** mark strategic throwaway words
- **Suggestion count** shows impact potential
- **Guidance text** explains when to use vs. when to go for answer
