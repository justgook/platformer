import replace from 'replace-in-file'
import colors from 'colors'

export default function replaceHtmlVars(options) {
  return {
    name: 'replaceHtmlVars',
    ongenerate: function () {
      try {
        var changes = replace.sync(options);
        console.log('\n\nRunning ' + 'replaceHtmlVars'.green + ' for files', changes.join(', ').green, '\n\n');
      }
      catch (error) {
        console.error('Error occurred:', error);
      }
    }
  };
};