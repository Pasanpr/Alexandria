#  Alexandria

Lightweight book lists 

## Task List

**Version 0.1**

- [x] Display first 10 books from every list on home page
- [x] Design better placeholder cover
- [x] Fix missing cover issues
- [ ] See all button for each list
- [x] Highlight Currently Reading section
- [ ] Create Book detail page
- [ ] Create list detail page

Issues:

- I switched to using the medium cover image to decrease download times but we now have an issue where
the covers vary b/w medium and large. This means that when the user taps to go to book detail, the cover they see
in the list detail will differ from book detail. No bueno.
- Proposed solution: Clean up download code.
    - Make sure that when a book goes offscreen the download is cancelled.
    - Cache data. 
Switch to the larger cover and see if this helps at all.


**Version 0.2**: Accessibility


