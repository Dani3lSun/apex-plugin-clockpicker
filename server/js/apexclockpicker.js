// APEX Clockpicker functions
// Author: Daniel Hochleitner
// Version: 1.7.0

// global namespace
var apexClockPicker = {
    // parse string to boolean
    parseBoolean: function(pString) {
        var pBoolean;
        if (pString.toLowerCase() == 'true') {
            pBoolean = true;
        }
        if (pString.toLowerCase() == 'false') {
            pBoolean = false;
        }
        if (!(pString.toLowerCase() == 'true') && !(pString.toLowerCase() == 'false')) {
            pBoolean = undefined;
        }
        return pBoolean;
    },
    // function that gets called from plugin
    initClockPicker: function(pItemId, pOptions, pLogging) {
        var vOptions = pOptions;
        var vPlacement = vOptions.placement;
        var vAlign = vOptions.align;
        var vAutoClose = apexClockPicker.parseBoolean(vOptions.autoclose);
        var vDoneText = vOptions.donetext;
        var vTwelveHour = apexClockPicker.parseBoolean(vOptions.twelvehour);
        var vShowButtonInt = vOptions.showbutton;
        var vLogging = apexClockPicker.parseBoolean(pLogging);
        var vShowButton;

        if (vShowButtonInt == 1 || vShowButtonInt == '1') {
            vShowButton = true;
        } else {
            vShowButton = false;
        }
        // Logging
        if (vLogging) {
            console.log('apexClockPicker: pItemId:', pItemId);
            console.log('apexClockPicker: vOptions.placement:', vOptions.placement);
            console.log('apexClockPicker: vOptions.align:', vOptions.align);
            console.log('apexClockPicker: vOptions.vAutoClose:', vOptions.autoclose);
            console.log('apexClockPicker: vOptions.vDoneText:', vOptions.donetext);
            console.log('apexClockPicker: vOptions.vTwelveHour:', vOptions.twelvehour);
            console.log('apexClockPicker: vOptions.vShowButton:', vOptions.showbutton);
        }
        // Clockpicker
        var clockPickerItem = $('#' + pItemId).clockpicker({
            "placement": vPlacement,
            "align": vAlign,
            "autoclose": vAutoClose,
            "donetext": vDoneText,
            "twelvehour": vTwelveHour,
            "default": "now"
        });
        // Clock Button
        if (vShowButton) {
            $('#' + pItemId + '_button').click(function(e) {
                e.stopPropagation();
                clockPickerItem.clockpicker('show');
            });
        }
        // APEX item
        apex.widget.initPageItem(pItemId, {
            disable: function() {
                apex.jQuery("#" + this.id).addClass("apex_disabled").prop("disabled", !0);
                apex.jQuery("#" + this.id + "_button").addClass("apex_disabled").prop("disabled", !0);
            },
            enable: function() {
                apex.jQuery("#" + this.id).removeClass("apex_disabled").prop("disabled", 0);
                apex.jQuery("#" + this.id + "_button").removeClass("apex_disabled").prop("disabled", 0);
            }
        });
    }
};
