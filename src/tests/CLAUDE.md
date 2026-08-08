# Testing Guidance

- This application uses PHPUnit. Write tests as PHPUnit classes, not Pest tests.
- Create tests with `php artisan make:test --phpunit`; most new coverage should be feature tests.
- Use model factories and their existing states. Follow the local test convention for `$this->faker` or `fake()`.
- Cover happy paths, failure paths, and relevant edge cases. Do not remove tests without approval.
- After updating tests, run the narrowest relevant test first: `php artisan test --compact <file>` or `php artisan test --compact --filter=<name>`.
- Offer to run the full suite after relevant tests pass: `php artisan test --compact`.
