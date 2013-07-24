exports = this
exports.data = {}
exports.data.roomDataRef = new Firebase firebaseURL+roomId
exports.data.isPublisher = false
exports.data.screenIsSharing = false

window.onload = ->
  screenleap.screenShareStarted = ->
    alertMsg "Your screen is now shared."
  screenleap.screenShareEnded = ->
    exports.data.roomDataRef.remove()

window.onbeforeunload = (e) ->
  e = e || window.event

  # detect window close so screen share can be stopped if active
  if e and exports.data.isPublisher and exports.data.screenIsSharing
    screenleap.stopSharing()

alertMsg = (html) ->
  $("#alertMsgDiv").html("")
  $("#alertMsgDiv").html(html)
  $("#alertMsgDiv").css {display: "block"}
  exports.data.interval = setInterval clearMsg, 4000
  
clearMsg = ->
  $("#alertMsgDiv").html("")
  clearInterval(exports.data.interval)

exports.data.roomDataRef.on "child_added", (snapshot) ->
  exports.data.screenIsSharing = true
  $("#shareButtonContainer").css({display: "none"})
  $("#stopButtonContainer").css({display: "block"}) if exports.data.isPublisher
  iframeHtml = """
    <iframe src="#{snapshot.val().viewerUrl}" width="800px" height="700px">
      <p>Your browser does not support iframes.</p>
    </iframe>
  """
  if exports.data.isPublisher then $("#iframeDiv").html("<h4>You are sharing screen now!</h4>") else $("#iframeDiv").html(iframeHtml)

exports.data.roomDataRef.on "child_removed", (snapshot) ->
  # clear all the divs
  $("#iframeDiv").html("")
  $("#stopButtonContainer").css({display: "none"})
  # show screen share button again
  $("#shareButtonContainer").css({display: "block"})
  alertMsg("Screen share ended")
  exports.data.screenIsSharing = false
  exports.data.isPublisher = false
  

makeScreenShareRequest = ->
  $.post "/screenleap", (res) ->
    screenShareData = JSON.parse(res)
    exports.data.isPublisher = true

    # remove the data from firebase only if the publisher leaves the room or stops sharing
    exports.data.roomDataRef.onDisconnect().remove()

    # hide the screenshare button for publisher, so the user doesn't click on it twice
    $("#shareButtonContainer").css({display: "none"})

    # start the screen share
    screenleap.startSharing "EXTENSION" , screenShareData
    $("#stopButtonContainer").css({display: "block"})

    # save viewerUrl on firebase
    exports.data.roomDataRef.push().set({viewerUrl : screenShareData.viewerUrl})

extensionInUse = ->
  alertMsg "Your screenleap extension is in use."

checkIsScreenSharing = ->
  screenleap.checkIsSharing extensionInUse, makeScreenShareRequest, "EXTENSION"

alertExtensionIsDisabled = ->
  alertMsg("Your screenleap extension is installed but not enabled. Please enable to share screen.")

initiateScreenShare = ->
  screenleap.checkIsExtensionEnabled checkIsScreenSharing, alertExtensionIsDisabled
  
installExtension = ->
  screenleap.installExtension makeScreenShareRequest, ->

$("#startScreenSharebtn").click ->
  screenleap.checkIsExtensionInstalled initiateScreenShare, installExtension

$("#stopScreenSharebtn").bind "click", ->
  screenleap.stopSharing()

 
