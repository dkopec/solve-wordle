// Please see documentation at https://learn.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Wordle letter box functionality
document.addEventListener('DOMContentLoaded', function() {
    const letterBoxes = document.querySelectorAll('.letter-box');
    const correctPositionsInput = document.getElementById('correctPositions');
    const form = document.getElementById('wordleForm');
    
    if (!letterBoxes.length) return;

    // Update hidden field when letter boxes change
    function updateCorrectPositions() {
        let pattern = '';
        letterBoxes.forEach(box => {
            pattern += box.value.trim() === '' ? '_' : box.value.toLowerCase();
        });
        if (correctPositionsInput) {
            correctPositionsInput.value = pattern;
        }
    }

    // Handle input in letter boxes
    letterBoxes.forEach((box, index) => {
        // Auto-focus next box on input
        box.addEventListener('input', function(e) {
            const value = e.target.value.toUpperCase();
            
            // Only allow letters
            if (value && !/^[A-Z]$/.test(value)) {
                e.target.value = '';
                return;
            }
            
            e.target.value = value;
            updateCorrectPositions();
            
            // Move to next box if letter entered
            if (value && index < letterBoxes.length - 1) {
                letterBoxes[index + 1].focus();
            }
        });

        // Handle backspace to move to previous box
        box.addEventListener('keydown', function(e) {
            if (e.key === 'Backspace' && !e.target.value && index > 0) {
                letterBoxes[index - 1].focus();
            }
            // Allow arrow key navigation
            else if (e.key === 'ArrowLeft' && index > 0) {
                letterBoxes[index - 1].focus();
            }
            else if (e.key === 'ArrowRight' && index < letterBoxes.length - 1) {
                letterBoxes[index + 1].focus();
            }
        });

        // Select all on focus for easy replacement
        box.addEventListener('focus', function(e) {
            e.target.select();
        });
    });

    // Update hidden field on form submit
    if (form) {
        form.addEventListener('submit', function() {
            updateCorrectPositions();
        });
    }

    // Initialize on page load
    updateCorrectPositions();
});

// Wrong Position Letters functionality
document.addEventListener('DOMContentLoaded', function() {
    const wrongPositionRows = document.getElementById('wrongPositionRows');
    const addRowBtn = document.getElementById('addWrongPosRow');
    const wrongPositionsInput = document.getElementById('wrongPositions');
    const form = document.getElementById('wordleForm');
    
    if (!wrongPositionRows) return;

    let rowCounter = 0;

    // Create a new row of letter boxes
    function createWrongPosRow() {
        rowCounter++;
        const rowDiv = document.createElement('div');
        rowDiv.className = 'd-flex gap-2 mb-2 align-items-center wrong-pos-row';
        rowDiv.dataset.rowId = rowCounter;
        
        let boxesHtml = '<div class="d-flex gap-2">';
        for (let i = 1; i <= 5; i++) {
            boxesHtml += `
                <input type="text" 
                       class="form-control text-center wrong-pos-box" 
                       maxlength="1" 
                       data-position="${i}"
                       data-row="${rowCounter}"
                       style="width: 50px; height: 50px; font-size: 20px; font-weight: bold; text-transform: uppercase;">
            `;
        }
        boxesHtml += '</div>';
        boxesHtml += `
            <button type="button" class="btn btn-sm btn-outline-danger remove-row" data-row="${rowCounter}">
                ×
            </button>
        `;
        
        rowDiv.innerHTML = boxesHtml;
        wrongPositionRows.appendChild(rowDiv);
        
        // Add event listeners to the new boxes
        attachWrongPosListeners(rowDiv);
        
        return rowDiv;
    }

    // Attach event listeners to wrong position boxes
    function attachWrongPosListeners(rowDiv) {
        const boxes = rowDiv.querySelectorAll('.wrong-pos-box');
        
        boxes.forEach((box, index) => {
            // Handle input
            box.addEventListener('input', function(e) {
                const value = e.target.value.toUpperCase();
                
                // Only allow letters
                if (value && !/^[A-Z]$/.test(value)) {
                    e.target.value = '';
                    return;
                }
                
                e.target.value = value;
                updateWrongPositions();
                
                // Move to next box if letter entered
                if (value && index < boxes.length - 1) {
                    boxes[index + 1].focus();
                }
            });

            // Handle backspace
            box.addEventListener('keydown', function(e) {
                if (e.key === 'Backspace' && !e.target.value && index > 0) {
                    boxes[index - 1].focus();
                }
                else if (e.key === 'ArrowLeft' && index > 0) {
                    boxes[index - 1].focus();
                }
                else if (e.key === 'ArrowRight' && index < boxes.length - 1) {
                    boxes[index + 1].focus();
                }
            });

            // Select all on focus
            box.addEventListener('focus', function(e) {
                e.target.select();
            });
        });
        
        // Remove row button
        const removeBtn = rowDiv.querySelector('.remove-row');
        if (removeBtn) {
            removeBtn.addEventListener('click', function() {
                rowDiv.remove();
                updateWrongPositions();
            });
        }
    }

    // Update hidden field with all wrong positions
    function updateWrongPositions() {
        const allBoxes = document.querySelectorAll('.wrong-pos-box');
        const entries = [];
        
        allBoxes.forEach(box => {
            const letter = box.value.trim().toLowerCase();
            const position = box.dataset.position;
            
            if (letter) {
                entries.push(`${letter}:${position}`);
            }
        });
        
        if (wrongPositionsInput) {
            wrongPositionsInput.value = entries.join(', ');
        }
    }

    // Parse existing wrong positions and create rows
    function loadExistingWrongPositions() {
        const existingValue = wrongPositionsInput ? wrongPositionsInput.value : '';
        if (!existingValue.trim()) {
            createWrongPosRow(); // Create one empty row by default
            return;
        }

        const entries = existingValue.split(',').map(e => e.trim());
        const positionMap = {}; // Group by rows (we'll create one row per unique set)
        
        entries.forEach(entry => {
            const parts = entry.split(':');
            if (parts.length === 2) {
                const letter = parts[0].trim();
                const position = parts[1].trim();
                
                // Create a simple grouping - one row for now
                if (!positionMap[0]) {
                    positionMap[0] = {};
                }
                positionMap[0][position] = letter;
            }
        });

        // Create rows from the grouped data
        if (Object.keys(positionMap).length > 0) {
            Object.values(positionMap).forEach(positions => {
                const row = createWrongPosRow();
                const boxes = row.querySelectorAll('.wrong-pos-box');
                
                boxes.forEach(box => {
                    const pos = box.dataset.position;
                    if (positions[pos]) {
                        box.value = positions[pos].toUpperCase();
                    }
                });
            });
        } else {
            createWrongPosRow(); // Create one empty row
        }
    }

    // Add row button
    if (addRowBtn) {
        addRowBtn.addEventListener('click', function() {
            createWrongPosRow();
        });
    }

    // Update hidden field on form submit
    if (form) {
        form.addEventListener('submit', function() {
            updateWrongPositions();
        });
    }

    // Initialize
    loadExistingWrongPositions();
});

// Excluded Letters functionality
document.addEventListener('DOMContentLoaded', function() {
    const excludedLetterBoxes = document.getElementById('excludedLetterBoxes');
    const addLetterBtn = document.getElementById('addExcludedLetter');
    const excludedLettersInput = document.getElementById('excludedLetters');
    const form = document.getElementById('wordleForm');
    
    if (!excludedLetterBoxes) return;

    let rowCounter = 0;

    // Create a new row of 5 excluded letter boxes
    function createExcludedLetterRow() {
        rowCounter++;
        const rowDiv = document.createElement('div');
        rowDiv.className = 'd-flex gap-2 mb-2 align-items-center excluded-letter-row';
        rowDiv.dataset.rowId = rowCounter;
        
        let boxesHtml = '<div class="d-flex gap-2">';
        for (let i = 1; i <= 5; i++) {
            boxesHtml += `
                <input type="text" 
                       class="form-control text-center excluded-letter-box" 
                       maxlength="1" 
                       data-position="${i}"
                       data-row="${rowCounter}"
                       style="width: 50px; height: 50px; font-size: 20px; font-weight: bold; text-transform: uppercase;">
            `;
        }
        boxesHtml += '</div>';
        
        rowDiv.innerHTML = boxesHtml;
        excludedLetterBoxes.appendChild(rowDiv);
        
        // Add event listeners to the new boxes
        attachExcludedLetterListeners(rowDiv);
        
        return rowDiv;
    }

    // Attach event listeners to excluded letter boxes
    function attachExcludedLetterListeners(rowDiv) {
        const boxes = rowDiv.querySelectorAll('.excluded-letter-box');
        
        boxes.forEach((box, index) => {
            // Handle input
            box.addEventListener('input', function(e) {
                const value = e.target.value.toUpperCase();
                
                // Only allow letters
                if (value && !/^[A-Z]$/.test(value)) {
                    e.target.value = '';
                    return;
                }
                
                // Get letters from correct positions (green)
                const correctLetters = new Set();
                document.querySelectorAll('.letter-box').forEach(box => {
                    const letter = box.value.trim().toUpperCase();
                    if (letter) correctLetters.add(letter);
                });
                
                // Get letters from wrong positions (yellow)
                const wrongPosLetters = new Set();
                document.querySelectorAll('.wrong-pos-box').forEach(box => {
                    const letter = box.value.trim().toUpperCase();
                    if (letter) wrongPosLetters.add(letter);
                });
                
                // Check if letter is already in correct or wrong position
                if (value && (correctLetters.has(value) || wrongPosLetters.has(value))) {
                    e.target.value = '';
                    // Show brief visual feedback
                    e.target.style.borderColor = 'red';
                    setTimeout(() => {
                        e.target.style.borderColor = '';
                    }, 500);
                    return;
                }
                
                // Check if letter already exists in excluded letters
                const allExcludedBoxes = document.querySelectorAll('.excluded-letter-box');
                let duplicateFound = false;
                allExcludedBoxes.forEach(otherBox => {
                    if (otherBox !== e.target && otherBox.value.toUpperCase() === value) {
                        duplicateFound = true;
                    }
                });
                
                if (duplicateFound) {
                    e.target.value = '';
                    // Show brief visual feedback
                    e.target.style.borderColor = 'orange';
                    setTimeout(() => {
                        e.target.style.borderColor = '';
                    }, 500);
                    return;
                }
                
                e.target.value = value;
                updateExcludedLetters();
                
                // Move to next box if letter entered
                if (value && index < boxes.length - 1) {
                    boxes[index + 1].focus();
                }
                // Auto-create new row when reaching the last box of the current row
                else if (value && index === boxes.length - 1) {
                    const allRows = document.querySelectorAll('.excluded-letter-row');
                    const currentRowIndex = Array.from(allRows).indexOf(rowDiv);
                    
                    // Check if this is the last row
                    if (currentRowIndex === allRows.length - 1) {
                        const newRow = createExcludedLetterRow();
                        const newBoxes = newRow.querySelectorAll('.excluded-letter-box');
                        newBoxes[0].focus();
                    } else {
                        // Focus first box of next row
                        const nextRow = allRows[currentRowIndex + 1];
                        const nextBoxes = nextRow.querySelectorAll('.excluded-letter-box');
                        nextBoxes[0].focus();
                    }
                }
            });

            // Handle backspace
            box.addEventListener('keydown', function(e) {
                if (e.key === 'Backspace' && !e.target.value && index > 0) {
                    boxes[index - 1].focus();
                }
                else if (e.key === 'ArrowLeft' && index > 0) {
                    boxes[index - 1].focus();
                }
                else if (e.key === 'ArrowRight' && index < boxes.length - 1) {
                    boxes[index + 1].focus();
                }
            });

            // Select all on focus
            box.addEventListener('focus', function(e) {
                e.target.select();
            });
        });
    }

    // Update hidden field with all excluded letters
    function updateExcludedLetters() {
        const allBoxes = document.querySelectorAll('.excluded-letter-box');
        const letters = [];
        
        allBoxes.forEach(box => {
            const letter = box.value.trim().toLowerCase();
            if (letter) {
                letters.push(letter);
            }
        });
        
        if (excludedLettersInput) {
            excludedLettersInput.value = letters.join('');
        }
    }

    // Load existing excluded letters into rows
    function loadExistingExcludedLetters() {
        const existingValue = excludedLettersInput ? excludedLettersInput.value : '';
        
        if (existingValue.trim()) {
            const letters = existingValue.toLowerCase().replace(/\s/g, '').split('');
            let currentRow = createExcludedLetterRow();
            let boxes = currentRow.querySelectorAll('.excluded-letter-box');
            let boxIndex = 0;
            
            letters.forEach((letter, index) => {
                if (letter) {
                    // If we've filled 5 boxes, create a new row
                    if (boxIndex >= 5) {
                        currentRow = createExcludedLetterRow();
                        boxes = currentRow.querySelectorAll('.excluded-letter-box');
                        boxIndex = 0;
                    }
                    
                    boxes[boxIndex].value = letter.toUpperCase();
                    boxIndex++;
                }
            });
        } else {
            // Create one empty row by default
            createExcludedLetterRow();
        }
    }

    // Add row button
    if (addLetterBtn) {
        addLetterBtn.addEventListener('click', function() {
            createExcludedLetterRow();
        });
    }

    // Update hidden field on form submit
    if (form) {
        form.addEventListener('submit', function() {
            updateExcludedLetters();
        });
    }

    // Initialize
    loadExistingExcludedLetters();
});

// Starting word suggestion click handler
document.addEventListener('DOMContentLoaded', function() {
    const startingWordBadges = document.querySelectorAll('.starting-word');
    
    startingWordBadges.forEach(badge => {
        badge.addEventListener('click', function() {
            const word = this.dataset.word.toLowerCase();
            const letterBoxes = document.querySelectorAll('.letter-box');
            
            if (letterBoxes.length >= 5 && word.length === 5) {
                for (let i = 0; i < 5; i++) {
                    letterBoxes[i].value = word[i].toUpperCase();
                }
                
                // Update the hidden field
                const correctPositionsInput = document.getElementById('correctPositions');
                if (correctPositionsInput) {
                    correctPositionsInput.value = word;
                }
                
                // Scroll to the form
                document.getElementById('wordleForm').scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });
});

// Remember exclude past answers checkbox preference
document.addEventListener('DOMContentLoaded', function() {
    const excludePastAnswersCheckbox = document.getElementById('excludePastAnswers');
    
    if (!excludePastAnswersCheckbox) return;
    
    // Load saved preference
    const savedPreference = localStorage.getItem('excludePastAnswers');
    if (savedPreference !== null) {
        excludePastAnswersCheckbox.checked = savedPreference === 'true';
    }
    
    // Save preference when changed
    excludePastAnswersCheckbox.addEventListener('change', function() {
        localStorage.setItem('excludePastAnswers', this.checked.toString());
    });
});

// Dark Mode Toggle
document.addEventListener('DOMContentLoaded', function() {
    const darkModeToggle = document.getElementById('darkModeToggle');
    const html = document.documentElement;
    const icon = darkModeToggle ? darkModeToggle.querySelector('i') : null;
    
    if (!darkModeToggle) return;

    // Check for saved theme preference or default to light mode
    const currentTheme = localStorage.getItem('theme') || 'light';
    html.setAttribute('data-bs-theme', currentTheme);
    updateIcon(currentTheme);

    // Toggle dark mode
    darkModeToggle.addEventListener('click', function() {
        const currentTheme = html.getAttribute('data-bs-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        
        html.setAttribute('data-bs-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        updateIcon(newTheme);
        
        // Add a little animation
        darkModeToggle.style.transform = 'rotate(360deg)';
        setTimeout(() => {
            darkModeToggle.style.transform = 'rotate(0deg)';
        }, 300);
    });

    function updateIcon(theme) {
        if (!icon) return;
        
        if (theme === 'dark') {
            icon.className = 'bi bi-sun-fill';
        } else {
            icon.className = 'bi bi-moon-stars-fill';
        }
    }
});

// Reset Button
document.addEventListener('DOMContentLoaded', function() {
    const resetButton = document.getElementById('resetButton');
    
    if (!resetButton) return;

    resetButton.addEventListener('click', function() {
        // Confirm reset
        if (confirm('Are you sure you want to reset all fields and start over?')) {
            // Clear all letter boxes
            document.querySelectorAll('.letter-box').forEach(box => {
                box.value = '';
            });
            
            // Clear and reset wrong position rows
            const wrongPosContainer = document.getElementById('wrongPositionRows');
            if (wrongPosContainer) {
                wrongPosContainer.innerHTML = '';
            }
            
            // Clear and reset excluded letter rows
            const excludedContainer = document.getElementById('excludedLetterBoxes');
            if (excludedContainer) {
                excludedContainer.innerHTML = '';
                // Reinitialize with one empty row
                if (typeof createExcludedLetterRow === 'function') {
                    // We need to trigger the initialization
                    const event = new Event('DOMContentLoaded');
                    // Just clear and let the page reload handle it
                }
            }
            
            // Clear hidden inputs
            const correctPositionsInput = document.getElementById('correctPositions');
            if (correctPositionsInput) correctPositionsInput.value = '';
            
            const wrongPositionsInput = document.getElementById('wrongPositions');
            if (wrongPositionsInput) wrongPositionsInput.value = '';
            
            const excludedLettersInput = document.getElementById('excludedLetters');
            if (excludedLettersInput) excludedLettersInput.value = '';
            
            // Reset checkbox
            const excludePastAnswers = document.getElementById('excludePastAnswers');
            if (excludePastAnswers) excludePastAnswers.checked = true;
            
            // Reload the page to reset everything cleanly
            window.location.href = window.location.pathname;
        }
    });
});

// Refresh Guess in One
document.addEventListener('DOMContentLoaded', function() {
    const refreshButton = document.getElementById('refreshGuessInOne');
    const guessInOneWord = document.getElementById('guessInOneWord');
    
    if (!refreshButton || !guessInOneWord) return;
    
    let offset = 0;

    refreshButton.addEventListener('click', async function() {
        offset++;
        
        // Show loading state
        const originalText = guessInOneWord.textContent;
        refreshButton.disabled = true;
        refreshButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Loading...';
        guessInOneWord.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span>';
        
        try {
            // Fetch new word from server
            const response = await fetch(`/api/guess-in-one?offset=${offset}`);
            if (response.ok) {
                const data = await response.json();
                guessInOneWord.textContent = data.word.toUpperCase();
            } else {
                // Fallback to client-side rotation through a predefined list
                const topWords = ['AROSE', 'SLATE', 'CRANE', 'STARE', 'AUDIO', 'ROATE', 'RAISE', 'ADIEU', 'SOARE'];
                guessInOneWord.textContent = topWords[offset % topWords.length];
            }
        } catch (error) {
            // Fallback to client-side rotation
            const topWords = ['AROSE', 'SLATE', 'CRANE', 'STARE', 'AUDIO', 'ROATE', 'RAISE', 'ADIEU', 'SOARE'];
            guessInOneWord.textContent = topWords[offset % topWords.length];
        } finally {
            // Restore button state
            refreshButton.disabled = false;
            refreshButton.innerHTML = '<i class="bi bi-arrow-clockwise"></i> Try Another Word';
        }
    });
});
