# Privacy Notes

A private notes application built with Rails 8 and Hotwire. Create, organize, and share notes with a clean, responsive interface.

## Features

- **Rich Text Notes**: Create notes with formatting, lists, and attachments using ActionText
- **Masonry Layout**: Notes displayed in a responsive Pinterest-style grid
- **Dark Mode**: Toggle between light and dark themes
- **Tags & Filtering**: Organize notes with tags and filter by tag
- **Pin Notes**: Pin important notes to the top
- **Archive**: Archive notes instead of deleting them
- **Version History**: View previous versions of your notes
- **Sharing**: Share notes with other users (view-only)
- **Autosave**: Notes automatically save as you type
- **Drag & Drop**: Reorder notes with drag and drop

## Requirements

- Ruby 3.3+
- SQLite 3

No Node.js or npm required! This project uses:
- Import maps for JavaScript
- Tailwind CSS standalone executable
- Propshaft asset pipeline

## Setup

```bash
# Clone the repository
git clone <repository-url>
cd notes-opus

# Install dependencies
bin/setup

# Start the development server
bin/dev
```

The app will be available at `http://localhost:3000`.

## Testing

```bash
# Run all tests
bin/rails test

# Run system tests
bin/rails test:system
```

## Code Quality

```bash
# Run Rubocop
bin/rubocop

# Run security checks
bin/brakeman
```

## Project Structure

- Uses vanilla Rails conventions
- Hotwire (Turbo + Stimulus) for frontend interactivity
- Solid Queue for background jobs
- Solid Cache for caching
- Solid Cable for Action Cable

See [STYLEGUIDE.md](STYLEGUIDE.md) for detailed coding conventions.

## License

MIT
