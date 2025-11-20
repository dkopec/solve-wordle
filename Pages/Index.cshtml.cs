using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using solve_wordle.Models;

namespace _.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    private readonly WordleSolver _solver;

    [BindProperty]
    public string? CorrectPositions { get; set; }

    [BindProperty]
    public string? WrongPositions { get; set; }

    [BindProperty]
    public string? ExcludedLetters { get; set; }

    [BindProperty]
    public bool ExcludePastAnswers { get; set; } = false;

    public List<WordSuggestion>? PossibleWords { get; set; }
    public List<WordSuggestion>? StrategicWords { get; set; }
    public List<string> BestStartingWords { get; set; } = new List<string>();
    public string? GuessInOne { get; set; }

    public IndexModel(ILogger<IndexModel> logger, WordleSolver solver)
    {
        _logger = logger;
        _solver = solver;
    }

    public void OnGet()
    {
        BestStartingWords = _solver.GetBestStartingWords(5);
        GuessInOne = _solver.GetGuessInOne();
    }

    public void OnPost()
    {
        BestStartingWords = _solver.GetBestStartingWords(5);
        GuessInOne = _solver.GetGuessInOne();
        
        if (!string.IsNullOrEmpty(CorrectPositions) || 
            !string.IsNullOrEmpty(WrongPositions) || 
            !string.IsNullOrEmpty(ExcludedLetters))
        {
            PossibleWords = _solver.GetRankedSuggestions(
                CorrectPositions ?? string.Empty,
                WrongPositions ?? string.Empty,
                ExcludedLetters ?? string.Empty,
                ExcludePastAnswers
            );
            
            // Generate strategic throwaway words to maximize elimination
            if (PossibleWords != null && PossibleWords.Count > 0)
            {
                var possibleWordsList = PossibleWords.Select(w => w.Word).ToList();
                StrategicWords = _solver.GetStrategicWords(
                    possibleWordsList, 
                    CorrectPositions ?? string.Empty,
                    ExcludedLetters ?? string.Empty,
                    5
                );
            }
        }
    }
}
