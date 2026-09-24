-- Treesitter parsers for Java projects, on top of kickstart's default list.
--
--   java   -> *.java
--   groovy -> *.gradle build scripts
--   kotlin -> *.gradle.kts build scripts
--   xml    -> pom.xml and other Maven/Spring XML
--
-- kickstart's FileType autocmd attaches highlighting and indentation once a parser is
-- installed, so nothing else is needed here.

require('nvim-treesitter').install { 'groovy', 'java', 'kotlin', 'xml' }
