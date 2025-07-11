
### Feature list
1. Aider ask
2. use `vim.fn.termopen()` start a backgroud terminal and start aider in it
3. use `vim.fn.chansend()` to send command to background aider
4. use `on_stdout` `on_stderr` `on_exit` to manage status and stdout of background aider
<!--5. support inline edit of output buffer-->
6. support @workspace @files @directories command like cursor
7. improve the code context logic to send the current code block to llm
   - Detect code blocks based on language syntax (indentation, brackets, etc)
   - Include relevant imports/requires when sending code
   - Support multiple cursor positions for context
   - Add surrounding function/class context when available
   - Maintain context history for follow-up questions
