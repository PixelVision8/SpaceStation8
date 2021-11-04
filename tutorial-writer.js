const tutorialWriter = require('tutorial-writer');
const fs = require('fs');
const path = require("path");
const chokidar = require('chokidar');

function toMarkdown(filePath)
{
 
    var text = fs.readFileSync(filePath, 'utf8');
    
    var basePath = path.dirname(filePath);
    var extension = path.extname(filePath);
    var file = path.basename(filePath, extension);

    var markdown = tutorialWriter.toMarkdown(path.basename(filePath), text, tutorialWriter.luaTemplate);
    
    var dest = ["Releases/Tutorial", file +extension+".md"].join(path.sep);

    var destDir = path.dirname(dest);

    if(!fs.existsSync(destDir))
    {
        fs.mkdirSync(destDir, { recursive: true });
    }

    fs.writeFile(dest, markdown, function (err) {
        if (err) return console.log(err);
        console.log(filePath, "to", dest);
      });

}

// One-liner for current directory
chokidar.watch(['Game/**/*.lua'], {
    ignored: 'node_modules'}).on('all', (event, path) => {
    toMarkdown(path);
});