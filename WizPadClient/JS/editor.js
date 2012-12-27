var EditorDivID = 'editedContent';
var WizNotCmdInditify = "<Wiznote-dzpqzb>";
var WizNotCmdChangedText = "changedText";
var WizNotCmdChangedImage = "changedImage";
var WizDeleteImageSpanName = "WizDeleteImageSpan";
var currentSelectImage = '';
function sendCmdToWiznote(cmd,content)
{
    var url =WizNotCmdInditify + cmd + WizNotCmdInditify + content;
    document.location = url;
}
function sendChangedTextMessage(content)
{
    sendCmdToWiznote(WizNotCmdChangedText,content);
}
function getDocumentEditedBodyHtml() {
    return document.body.innerHTML;
}
function getDocumentEditedBody()
{
	return document.body;
}

function touchOnImage(e) {
    var targ
    if(!e)
        var e = window.event
        if(e.target)
            targ = e.target
        else if(e.srcElement)
            targ = e.srcElement
        if(targ.nodeType == 3)// defeat Safari bug
            targ = targ.parentNode
        var tname
        tname = targ.tagName
        if (tname == 'IMG')
        {
            currentSelectImage = targ;
            sendCmdToWiznote(WizNotCmdChangedImage,targ.src)
        };
}
function deleteImage()
{
    currentSelectImage.parentElement.removeChild(currentSelectImage);
}

function initRootElement()
{
    document.body.setAttribute('contentEditable', true);
    document.onmousedown = touchOnImage;
}
function insertPhoto(path)
{
	root = getDocumentEditedBody();
	root.focus();
	
	img = document.createElement('img');
	img.setAttribute('src',path);
	
	root.appendChild(img);
}


function insertAudio(path)
{
	root = getDocumentEditedBody();
	root.focus();
	
	audio = document.createElement('embed');
	audio.setAttribute('src',path);
	audio.setAttribute('autostart',false);
	
	root.appendChild(audio);
	// embed src=\"index_files/%@\" autostart=false
}
function insertText(text)
{
	var selection = document.getSelection();
	var baseNode  = selection.baseNode;
	var baseNodeStr = baseNode.nodeValue;
	var offset = selection.baseOffset;
	baseNode.nodeValue = baseNodeStr.substr(0,offset) + text + baseNodeStr.substr(offset,baseNodeStr.length);
}
initRootElement();