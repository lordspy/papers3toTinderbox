Project created by Rodrigo de Godoy Domingues
Uberlândia - MG - Brazil
04/12/2015

Script to retreive Papers3 documents and generate tinderbox like XML.
The XML is not tinderbox complete, it is aimed to be pasted into existing tinderbox project.
Prototypes are being ignored for some reason when opening tinderbox. Their entries are erased.

Generates the following structure:

References
   Papers
   Books
      For each book, book chapters when available
   Websites
   Keywords
      Every Keyword present in Papers3
        Documents that contains the keyword
Authors
  Every author present in Papers3
    Publications the Author wrote

Every note color depends on the rating assigned in Papers3
5 stars: Green
4 stars: Blue
3 stars: Yellow
2 stars: orange
1 star: Red
0 star: White
0 star + flagged: Grey

A tinderbox template file is provided for reference

TODO: Generate the whole tinderbox document
TODO: Improve the user interface (so far just 2 dialogs 1 to inform the process is about to begin and other to inform the completion)
TODO: Checkout the time out in application (Papers 3) error. This is my very first applescript, it surelly is my fault in some misunderstanding of things
TODO: Improve code documentation