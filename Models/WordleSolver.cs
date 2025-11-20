namespace solve_wordle.Models;

public class WordSuggestion
{
    public string Word { get; set; } = string.Empty;
    public double Score { get; set; }
    public int Rank { get; set; }
    public double ConfidencePercentage { get; set; }
}

public class WordleSolver
{
    private readonly List<string> _wordList;
    private readonly HashSet<string> _pastAnswers;
    private readonly HashSet<string> _commonWords;
    private List<string>? _cachedBestStartingWords;
    private Dictionary<char, int>? _letterFrequency;
    private Dictionary<int, Dictionary<char, int>>? _positionFrequency;
    private Dictionary<string, int>? _bigramFrequency;
    private Dictionary<string, int>? _trigramFrequency;
    private Dictionary<char, double>? _vowelPositionScores;
    private HashSet<string>? _commonPatterns;
    private Dictionary<string, double>? _wordCommonality;

    public WordleSolver(List<string> wordList, HashSet<string> pastAnswers, HashSet<string> commonWords)
    {
        _wordList = wordList;
        _pastAnswers = pastAnswers;
        _commonWords = commonWords;
        InitializeFrequencyData();
    }

    private void InitializeFrequencyData()
    {
        _letterFrequency = new Dictionary<char, int>();
        _positionFrequency = new Dictionary<int, Dictionary<char, int>>();
        _bigramFrequency = new Dictionary<string, int>();
        _trigramFrequency = new Dictionary<string, int>();
        _vowelPositionScores = new Dictionary<char, double>();
        _commonPatterns = new HashSet<string>();
        _wordCommonality = new Dictionary<string, double>();
        
        // Calculate word commonality scores with proper prioritization
        // 1. Past Wordle answers - HIGHEST priority (these are proven good words)
        foreach (var word in _pastAnswers)
        {
            _wordCommonality[word] = 1000.0; // Very high score for actual past answers
        }
        
        // 2. Common English words - HIGH priority (ranked by frequency)
        var commonWordsList = _commonWords.ToList();
        for (int i = 0; i < commonWordsList.Count; i++)
        {
            var word = commonWordsList[i];
            if (!_wordCommonality.ContainsKey(word))
            {
                // Earlier in common words list = more frequent in English
                // Score range: 900 (first) down to ~400 (last)
                var commonScore = 900.0 - (i * 500.0 / Math.Max(1, commonWordsList.Count));
                _wordCommonality[word] = Math.Max(400, commonScore);
            }
        }
        
        // 3. All other words - LOWER priority (based on position in master list)
        for (int i = 0; i < _wordList.Count; i++)
        {
            var word = _wordList[i];
            if (!_wordCommonality.ContainsKey(word))
            {
                // Logarithmic decay for uncommon words
                // Score range: ~100 down to near 0
                var positionScore = Math.Max(0, 100 - Math.Log(i + 1) * 8);
                _wordCommonality[word] = positionScore;
            }
        }
        
        for (int i = 0; i < 5; i++)
        {
            _positionFrequency[i] = new Dictionary<char, int>();
        }

        foreach (var word in _pastAnswers)
        {
            var uniqueLetters = new HashSet<char>();
            for (int i = 0; i < word.Length && i < 5; i++)
            {
                var letter = word[i];
                
                if (!uniqueLetters.Contains(letter))
                {
                    _letterFrequency[letter] = _letterFrequency.GetValueOrDefault(letter, 0) + 1;
                    uniqueLetters.Add(letter);
                }
                
                _positionFrequency[i][letter] = _positionFrequency[i].GetValueOrDefault(letter, 0) + 1;
                
                // Track bigrams
                if (i < 4)
                {
                    var bigram = word.Substring(i, 2);
                    _bigramFrequency[bigram] = _bigramFrequency.GetValueOrDefault(bigram, 0) + 1;
                }
                
                // Track trigrams
                if (i < 3)
                {
                    var trigram = word.Substring(i, 3);
                    _trigramFrequency[trigram] = _trigramFrequency.GetValueOrDefault(trigram, 0) + 1;
                }
            }
            
            // Track common ending patterns
            if (word.Length >= 2)
            {
                _commonPatterns.Add(word.Substring(word.Length - 2)); // last 2 letters
                if (word.Length >= 3)
                    _commonPatterns.Add(word.Substring(word.Length - 3)); // last 3 letters
            }
        }
        
        // Calculate vowel position preferences
        var vowels = new[] { 'a', 'e', 'i', 'o', 'u' };
        foreach (var vowel in vowels)
        {
            double totalScore = 0;
            for (int i = 0; i < 5; i++)
            {
                totalScore += _positionFrequency[i].GetValueOrDefault(vowel, 0) * (i + 1); // Weight later positions slightly higher
            }
            _vowelPositionScores[vowel] = totalScore;
        }
    }

    public List<string> FilterWords(
        string correctPositions,
        string wrongPositions,
        string excludedLetters,
        bool excludePastAnswers = true)
    {
        var suggestions = GetRankedSuggestions(correctPositions, wrongPositions, excludedLetters, excludePastAnswers);
        return suggestions.Select(s => s.Word).ToList();
    }

    public List<WordSuggestion> GetRankedSuggestions(
        string correctPositions,
        string wrongPositions,
        string excludedLetters,
        bool excludePastAnswers = true)
    {
        var possibleWords = new List<string>(_wordList);

        // Filter by correct positions (green letters)
        possibleWords = FilterByCorrectPositions(possibleWords, correctPositions);

        // Filter by wrong positions (yellow letters)
        possibleWords = FilterByWrongPositions(possibleWords, wrongPositions);

        // Filter by excluded letters (gray letters)
        possibleWords = FilterByExcludedLetters(possibleWords, excludedLetters);

        // Exclude previous Wordle answers
        if (excludePastAnswers)
        {
            possibleWords = possibleWords.Where(w => !_pastAnswers.Contains(w)).ToList();
        }

        // Score and rank the words
        var scoredWords = possibleWords
            .Select(word => new
            {
                Word = word,
                Score = CalculateWordScore(word, _letterFrequency!, _positionFrequency!)
            })
            .OrderByDescending(w => w.Score)
            .ToList();

        // Calculate confidence percentages
        var maxScore = scoredWords.Any() ? scoredWords.Max(w => w.Score) : 0;
        var minScore = scoredWords.Any() ? scoredWords.Min(w => w.Score) : 0;
        var scoreRange = maxScore - minScore;

        var suggestions = scoredWords
            .Select((item, index) => new WordSuggestion
            {
                Word = item.Word,
                Score = item.Score,
                Rank = index + 1,
                ConfidencePercentage = CalculateConfidence(item.Score, maxScore, minScore, scoreRange, scoredWords.Count)
            })
            .ToList();

        return suggestions;
    }

    public List<WordSuggestion> GetStrategicWords(
        List<string> possibleWords,
        string correctPositions,
        string excludedLetters = "",
        int count = 5)
    {
        // Suggest strategic "throwaway" words that help eliminate possibilities
        // Continue suggesting even with low word counts for optimal play
        
        if (possibleWords.Count == 0)
            return new List<WordSuggestion>(); // No suggestions if no possibilities

        // Extract green (correct) letters to EXCLUDE from strategic words
        var greenLetters = new HashSet<char>();
        if (!string.IsNullOrWhiteSpace(correctPositions))
        {
            foreach (var c in correctPositions)
            {
                if (c != '_' && c != ' ')
                {
                    greenLetters.Add(char.ToLower(c));
                }
            }
        }
        
        // Extract excluded (gray) letters to EXCLUDE from strategic words
        var grayLetters = new HashSet<char>();
        if (!string.IsNullOrWhiteSpace(excludedLetters))
        {
            foreach (var c in excludedLetters)
            {
                if (char.IsLetter(c))
                {
                    grayLetters.Add(char.ToLower(c));
                }
            }
        }

        // Analyze which letters appear in possible words
        var letterCoverage = new Dictionary<char, int>();
        var positionLetterCoverage = new Dictionary<int, Dictionary<char, int>>();
        
        for (int i = 0; i < 5; i++)
        {
            positionLetterCoverage[i] = new Dictionary<char, int>();
        }

        foreach (var word in possibleWords)
        {
            var seenLetters = new HashSet<char>();
            for (int i = 0; i < word.Length && i < 5; i++)
            {
                var letter = word[i];
                
                // Skip green letters - we already know these are correct
                if (greenLetters.Contains(letter))
                    continue;
                
                // Count how many possible words contain each letter
                if (!seenLetters.Contains(letter))
                {
                    letterCoverage[letter] = letterCoverage.GetValueOrDefault(letter, 0) + 1;
                    seenLetters.Add(letter);
                }
                
                // Count position-specific coverage (excluding green letters)
                positionLetterCoverage[i][letter] = positionLetterCoverage[i].GetValueOrDefault(letter, 0) + 1;
            }
        }

        // Find words that cover the most uncertain letters
        var strategicWords = _wordList
            .Where(w => !possibleWords.Contains(w)) // Don't suggest words already in possible answers
            .Where(w => !greenLetters.Any(gl => w.Contains(gl))) // CRITICAL: Exclude words with ANY green letters
            .Where(w => !grayLetters.Any(el => w.Contains(el))) // CRITICAL: Exclude words with ANY excluded letters
            .Select(word => new
            {
                Word = word,
                Score = CalculateStrategicScore(word, letterCoverage, positionLetterCoverage, possibleWords.Count, greenLetters, grayLetters)
            })
            .OrderByDescending(w => w.Score)
            .Take(count)
            .Select((item, index) => new WordSuggestion
            {
                Word = item.Word,
                Score = item.Score,
                Rank = index + 1,
                ConfidencePercentage = 0 // Not applicable for strategic words
            })
            .ToList();

        return strategicWords;
    }

    private double CalculateStrategicScore(
        string word,
        Dictionary<char, int> letterCoverage,
        Dictionary<int, Dictionary<char, int>> positionLetterCoverage,
        int totalPossibleWords,
        HashSet<char> greenLetters,
        HashSet<char> grayLetters)
    {
        double score = 0;
        var uniqueLetters = new HashSet<char>();
        var vowels = new HashSet<char> { 'a', 'e', 'i', 'o', 'u' };
        int vowelCount = 0;

        for (int i = 0; i < word.Length && i < 5; i++)
        {
            var letter = word[i];
            
            // CRITICAL: Skip and penalize if word contains any green letters
            if (greenLetters.Contains(letter))
            {
                return 0; // Disqualify this word entirely
            }
            
            // CRITICAL: Skip and penalize if word contains any excluded (gray) letters
            if (grayLetters.Contains(letter))
            {
                return 0; // Disqualify this word entirely
            }
            
            // High score for letters that appear in many possible words
            if (!uniqueLetters.Contains(letter))
            {
                var coverage = letterCoverage.GetValueOrDefault(letter, 0);
                // MAXIMIZE ELIMINATION: Letters appearing in 40-60% of words split possibilities best
                var coverageRatio = (double)coverage / totalPossibleWords;
                
                if (coverageRatio >= 0.4 && coverageRatio <= 0.6)
                {
                    score += coverage * 15; // HIGHEST value - perfect 50/50 split potential
                }
                else if (coverageRatio >= 0.3 && coverageRatio < 0.4)
                {
                    score += coverage * 12; // Good discrimination
                }
                else if (coverageRatio > 0.6 && coverageRatio <= 0.75)
                {
                    score += coverage * 12; // Still valuable
                }
                else if (coverageRatio > 0.15)
                {
                    score += coverage * 5; // Some value
                }
                
                uniqueLetters.Add(letter);
            }
            
            // Position-specific coverage bonus
            var positionCoverage = positionLetterCoverage[i].GetValueOrDefault(letter, 0);
            score += positionCoverage * 2;
            
            if (vowels.Contains(letter))
            {
                vowelCount++;
            }
        }

        // Strong bonus for 5 unique letters (maximum information)
        if (uniqueLetters.Count == 5)
        {
            score *= 3.0; // INCREASED from 2.5 - we want max elimination
        }
        else if (uniqueLetters.Count == 4)
        {
            score *= 1.8; // INCREASED from 1.5
        }
        else
        {
            score *= 0.3; // Heavy penalty for repeated letters - wasted information
        }

        // Prefer words with 2-3 vowels (typical word structure)
        if (vowelCount >= 2 && vowelCount <= 3)
        {
            score *= 1.3;
        }

        // Bonus for common letters that provide broad coverage
        var commonLetters = new HashSet<char> { 'e', 'a', 'r', 'o', 't', 'l', 'i', 's', 'n', 'c' };
        var commonCount = word.Count(c => commonLetters.Contains(c) && uniqueLetters.Contains(c));
        score += commonCount * 20;
        
        // Moderate bonus for word commonality (still want real words, not gibberish)
        // But don't over-weight it - strategic words prioritize information, not likelihood
        var commonality = _wordCommonality!.GetValueOrDefault(word, 0);
        if (commonality > 300)
        {
            score *= 1.2; // Slight boost for recognizable words
        }
        else if (commonality < 20)
        {
            score *= 0.5; // Penalty for very obscure words
        }

        return score;
    }

    private double CalculateConfidence(double score, double maxScore, double minScore, double scoreRange, int totalWords)
    {
        if (totalWords == 1)
            return 98.0; // Very high confidence if only one word

        if (scoreRange == 0)
            return 60.0; // Moderate confidence if all equal

        // Normalize score (0 to 1)
        var normalizedScore = (score - minScore) / scoreRange;
        
        // AGGRESSIVE exponential curve - heavily favor top matches
        // Top word gets much higher confidence than second
        var baseConfidence = Math.Pow(normalizedScore, 0.4) * 75 + 10;
        
        // Aggressive word count adjustment
        var wordCountFactor = 1.0;
        if (totalWords == 2)
            wordCountFactor = 1.35; // Very high confidence for top when only 2 options
        else if (totalWords <= 3)
            wordCountFactor = 1.25;
        else if (totalWords <= 5)
            wordCountFactor = 1.20;
        else if (totalWords <= 10)
            wordCountFactor = 1.10;
        else if (totalWords <= 20)
            wordCountFactor = 0.95;
        else if (totalWords <= 50)
            wordCountFactor = 0.85;
        else
            wordCountFactor = 0.70; // Lower confidence when many options
        
        var confidence = baseConfidence * wordCountFactor;
        
        // Additional boost for #1 ranked word
        if (normalizedScore == 1.0 && totalWords > 1)
        {
            // Calculate gap between #1 and #2
            confidence = Math.Min(confidence * 1.15, 98.0);
        }
        
        // Cap at bounds (wider range for more differentiation)
        return Math.Min(Math.Max(confidence, 3.0), 98.0);
    }

    private List<string> FilterByCorrectPositions(List<string> words, string correctPositions)
    {
        if (string.IsNullOrWhiteSpace(correctPositions))
            return words;

        return words.Where(word =>
        {
            for (int i = 0; i < correctPositions.Length && i < 5; i++)
            {
                if (correctPositions[i] != '_' && word[i] != char.ToLower(correctPositions[i]))
                    return false;
            }
            return true;
        }).ToList();
    }

    private List<string> FilterByWrongPositions(List<string> words, string wrongPositions)
    {
        if (string.IsNullOrWhiteSpace(wrongPositions))
            return words;

        var entries = wrongPositions.Split(',', StringSplitOptions.RemoveEmptyEntries);
        
        return words.Where(word =>
        {
            foreach (var entry in entries)
            {
                var parts = entry.Trim().Split(':');
                if (parts.Length != 2) continue;

                var letter = char.ToLower(parts[0][0]);
                if (!int.TryParse(parts[1], out int position) || position < 1 || position > 5)
                    continue;

                // Word must contain the letter
                if (!word.Contains(letter))
                    return false;

                // But not at the specified position (1-indexed)
                if (word[position - 1] == letter)
                    return false;
            }
            return true;
        }).ToList();
    }

    private List<string> FilterByExcludedLetters(List<string> words, string excludedLetters)
    {
        if (string.IsNullOrWhiteSpace(excludedLetters))
            return words;

        var excluded = excludedLetters.ToLower().Replace(" ", "").ToCharArray();
        
        return words.Where(word =>
            !excluded.Any(letter => word.Contains(letter))
        ).ToList();
    }

    public List<string> GetBestStartingWords(int count = 5)
    {
        if (_cachedBestStartingWords != null)
            return _cachedBestStartingWords.Take(count).ToList();

        // Score each word in the word list using pre-calculated frequency data
        var scoredWords = _wordList
            .Where(w => !_pastAnswers.Contains(w)) // Exclude past answers
            .Select(word => new
            {
                Word = word,
                Score = CalculateWordScore(word, _letterFrequency!, _positionFrequency!)
            })
            .OrderByDescending(w => w.Score)
            .Select(w => w.Word)
            .ToList();

        _cachedBestStartingWords = scoredWords;
        return scoredWords.Take(count).ToList();
    }

    public string GetGuessInOne()
    {
        return GetGuessInOne(0);
    }

    public string GetGuessInOne(int offset)
    {
        // Get top candidates from past Wordle answers
        var topCandidates = _pastAnswers
            .Select(word => new
            {
                Word = word,
                Score = CalculateWordScore(word, _letterFrequency!, _positionFrequency!)
            })
            .OrderByDescending(w => w.Score)
            .Take(100) // Take top 100 for more variety
            .Select(w => w.Word)
            .ToList();

        if (!topCandidates.Any())
        {
            return "arose"; // Fallback
        }

        // Use date-based seed plus offset for semi-random selection
        // Changes daily but stays consistent throughout the day
        var today = DateTime.Today;
        var seed = today.Year * 10000 + today.Month * 100 + today.Day + (offset * 1000);
        var random = new Random(seed);
        
        // Pick from top candidates with weighted probability
        // Higher probability for top-ranked words
        var index = (int)(Math.Pow(random.NextDouble(), 2) * topCandidates.Count);
        return topCandidates[Math.Min(index, topCandidates.Count - 1)];
    }

    private double CalculateWordScore(string word, Dictionary<char, int> letterFrequency, Dictionary<int, Dictionary<char, int>> positionFrequency)
    {
        double score = 0;
        var uniqueLetters = new HashSet<char>();
        var vowels = new HashSet<char> { 'a', 'e', 'i', 'o', 'u' };
        int vowelCount = 0;

        // 1. Position-specific letter frequency (HIGHEST WEIGHT)
        for (int i = 0; i < word.Length && i < 5; i++)
        {
            var letter = word[i];
            
            // Aggressive position-specific scoring
            score += positionFrequency[i].GetValueOrDefault(letter, 0) * 5.0;
            
            // Track unique letters and vowels
            if (!uniqueLetters.Contains(letter))
            {
                score += letterFrequency.GetValueOrDefault(letter, 0) * 3.0;
                uniqueLetters.Add(letter);
            }
            
            if (vowels.Contains(letter))
            {
                vowelCount++;
                score += _vowelPositionScores!.GetValueOrDefault(letter, 0) * 0.5;
            }
        }

        // 2. Bigram analysis - VERY IMPORTANT for real words
        for (int i = 0; i < word.Length - 1; i++)
        {
            var bigram = word.Substring(i, 2);
            score += _bigramFrequency!.GetValueOrDefault(bigram, 0) * 3.5;
        }
        
        // 3. Trigram analysis - even more predictive
        for (int i = 0; i < word.Length - 2; i++)
        {
            var trigram = word.Substring(i, 3);
            score += _trigramFrequency!.GetValueOrDefault(trigram, 0) * 4.0;
        }

        // 4. Common ending patterns
        if (word.Length >= 2)
        {
            var ending2 = word.Substring(word.Length - 2);
            if (_commonPatterns!.Contains(ending2))
                score += 50;
            
            if (word.Length >= 3)
            {
                var ending3 = word.Substring(word.Length - 3);
                if (_commonPatterns.Contains(ending3))
                    score += 75;
            }
        }

        // 5. Optimal vowel distribution (1-3 vowels is ideal for Wordle)
        if (vowelCount >= 1 && vowelCount <= 3)
        {
            if (vowelCount == 2)
                score *= 1.4; // Two vowels is most common
            else
                score *= 1.2;
        }
        else if (vowelCount == 0 || vowelCount > 3)
        {
            score *= 0.4; // Heavy penalty for unusual vowel counts
        }

        // 6. Unique letter bonus (diverse letters still valuable)
        if (uniqueLetters.Count == 5)
        {
            score *= 1.3; // Bonus for all unique letters
        }
        else if (uniqueLetters.Count == 4)
        {
            score *= 1.0; // Neutral for one repeated letter (very common in Wordle)
        }
        else if (uniqueLetters.Count == 3)
        {
            score *= 0.7; // Moderate penalty for two repeated letters
        }
        else
        {
            score *= 0.4; // Heavy penalty for 3+ repeated letters
        }
        
        // 7. Bonus if word was actually a past answer (pattern match)
        if (_pastAnswers.Contains(word))
        {
            score *= 1.8; // Strong bonus for words matching past answer patterns
        }
        
        // 8. Word commonality - MAJOR FACTOR for realistic answers
        var commonality = _wordCommonality!.GetValueOrDefault(word, 0);
        score += commonality * 2.0; // Significant boost for common words
        
        // Additional multiplier for very common words
        if (commonality > 800)
        {
            score *= 1.5; // Past Wordle answers get extra boost
        }
        else if (commonality > 400)
        {
            score *= 1.3; // Common English words
        }
        else if (commonality > 200)
        {
            score *= 1.15; // Moderately common words
        }
        else if (commonality < 50)
        {
            score *= 0.6; // Penalty for rare/obscure words
        }
        
        // 9. Common starting letters (s, c, p, t, a, b are common)
        var commonStarters = new HashSet<char> { 's', 'c', 'p', 't', 'a', 'b', 'r', 'l', 'm', 'f' };
        if (commonStarters.Contains(word[0]))
        {
            score *= 1.15;
        }

        return score;
    }
}
