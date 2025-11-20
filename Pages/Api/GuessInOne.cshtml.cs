using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using solve_wordle.Models;
using System.Text.Json;

namespace solve_wordle.Pages.Api
{
    public class GuessInOneModel : PageModel
    {
        private readonly WordleSolver _solver;

        public GuessInOneModel(WordleSolver solver)
        {
            _solver = solver;
        }

        public IActionResult OnGet(int offset = 0)
        {
            var word = _solver.GetGuessInOne(offset);
            return new JsonResult(new { word = word });
        }
    }
}
