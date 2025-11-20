namespace solve_wordle.Services;

public class WordListService
{
    private readonly List<string> _words;
    private readonly HashSet<string> _pastAnswers;
    private readonly HashSet<string> _commonWords;

    public WordListService(IWebHostEnvironment env)
    {
        var wordFilePath = Path.Combine(env.ContentRootPath, "Data", "words.txt");
        var pastAnswersPath = Path.Combine(env.ContentRootPath, "Data", "past-answers.txt");
        var commonWordsPath = Path.Combine(env.ContentRootPath, "Data", "common-words.txt");
        
        if (File.Exists(wordFilePath))
        {
            _words = File.ReadAllLines(wordFilePath)
                .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length == 5)
                .Select(w => w.ToLower().Trim())
                .Distinct()
                .OrderBy(w => w)
                .ToList();
        }
        else
        {
            _words = new List<string>();
        }

        if (File.Exists(pastAnswersPath))
        {
            _pastAnswers = File.ReadAllLines(pastAnswersPath)
                .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length == 5)
                .Select(w => w.ToLower().Trim())
                .ToHashSet();
        }
        else
        {
            _pastAnswers = new HashSet<string>();
        }

        if (File.Exists(commonWordsPath))
        {
            _commonWords = File.ReadAllLines(commonWordsPath)
                .Where(w => !string.IsNullOrWhiteSpace(w) && w.Length == 5)
                .Select(w => w.ToLower().Trim())
                .ToHashSet();
        }
        else
        {
            _commonWords = new HashSet<string>();
        }
    }

    public List<string> GetWords() => _words;
    public HashSet<string> GetPastAnswers() => _pastAnswers;
    public HashSet<string> GetCommonWords() => _commonWords;
}
