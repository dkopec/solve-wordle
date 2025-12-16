namespace solve_wordle.Services;

public class WordListService
{
    private readonly HttpClient _httpClient;
    private List<string>? _words;
    private HashSet<string>? _pastAnswers;
    private HashSet<string>? _commonWords;
    private bool _isInitialized = false;

    public WordListService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task InitializeAsync()
    {
        if (_isInitialized)
            return;

        try
        {
            // Load words
            var wordsText = await _httpClient.GetStringAsync("data/words.txt");
            _words = wordsText.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length == 5)
                .Select(w => w.ToLower().Trim())
                .Distinct()
                .OrderBy(w => w)
                .ToList();

            // Load past answers
            var pastAnswersText = await _httpClient.GetStringAsync("data/past-answers.txt");
            _pastAnswers = pastAnswersText.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length == 5)
                .Select(w => w.ToLower().Trim())
                .ToHashSet();

            // Load common words
            var commonWordsText = await _httpClient.GetStringAsync("data/common-words.txt");
            _commonWords = commonWordsText.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries)
                .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length == 5)
                .Select(w => w.ToLower().Trim())
                .ToHashSet();

            _isInitialized = true;
        }
        catch (Exception)
        {
            // Fallback to empty lists if files can't be loaded
            _words = new List<string>();
            _pastAnswers = new HashSet<string>();
            _commonWords = new HashSet<string>();
            _isInitialized = true;
        }
    }

    public List<string> GetWords() => _words ?? new List<string>();
    public HashSet<string> GetPastAnswers() => _pastAnswers ?? new HashSet<string>();
    public HashSet<string> GetCommonWords() => _commonWords ?? new HashSet<string>();
}
