import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import ClassSchedule;

class WatchFace1View extends WatchUi.WatchFace {
    var cx, cy, radius;
    var lastSecAngle = null;

    const BG = Graphics.COLOR_BLACK;
    const FG = Graphics.COLOR_WHITE;
    const HL = Graphics.COLOR_YELLOW;
    const SEC = Graphics.COLOR_RED;
    const J = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    const JR = Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_CENTER;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        cx = w / 2;
        cy = h / 2;
        radius = (w < h ? w : h) / 2 - 10;

        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(BG, BG);
        dc.clear();

        // Get Current Time
        var now = System.getClockTime();
        var hour = now.hour % 12;
        var minute = now.min;
        var second = now.sec;

        // Draws inward-facing triangles at 12, 3, 6, and 9 o'clock positions, but no minute ticks
        // drawCardinalTicks(dc);

        // Draws inward-facing triangles every 10 ticks + minute ticks
        drawHexagonalTicks(dc, minute);

        // Draw all hour numbers
        /*
        var textR = radius - 30; // small inward offset
        for (var i = 0; i < 12; i++) {
            var a  = (i / 12.0) * 2 * Math.PI - Math.PI/2;
            var tx = cx + Math.cos(a) * textR;
            var ty = cy + Math.sin(a) * textR;

            var label = (i == 0 ? "12" : i.toString());
            dc.setColor(i == hour ? HL : FG, Graphics.COLOR_TRANSPARENT);
            dc.drawText(tx, ty, Graphics.FONT_NUMBER_MEDIUM, label, J); // <- horizontal + vertical center
        } 
        */

        // Dial numbers
        // drawActiveHour(dc, hour);
        drawActiveHourCentered(dc, hour);
        drawHourCircle(dc);

        // Hands
        // drawHourHand(dc, hour, minute);
        drawMinuteHand(dc, minute);
        drawMinuteHandPointer(dc, minute);
        drawSecondHand(dc, second);

        // Text
        drawDateString(dc);
        drawClasses(dc);
    }
    function drawActiveHour(dc as Dc, hour as Number) {
        var textR = radius - 32;
        var a = (hour / 12.0) * 2 * Math.PI - Math.PI/2;
        var tx = cx + Math.cos(a) * textR;
        var ty = cy + Math.sin(a) * textR;
        var label = hour.toNumber() == 0 ? "12" : hour.toString();
        dc.setColor(HL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(tx, ty, Graphics.FONT_NUMBER_MEDIUM, label, J);
    }
    function drawActiveHourCentered(dc as Dc, hour as Number) {
        var label = hour.toNumber() == 0 ? "12" : hour.toString();
        var labelHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
        dc.setColor(HL, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - labelHeight / 2, Graphics.FONT_NUMBER_MEDIUM, label, Graphics.TEXT_JUSTIFY_CENTER);
    }
    function drawHourCircle(dc as Dc) {
        var radius = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM) / 2;
        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);
    }
    function drawHourHand(dc as Dc, hour as Number, minute as Number) {
        var hourAngle = ((hour + minute / 60.0) / 12.0) * 2 * Math.PI - Math.PI/2;
        dc.setPenWidth(2);
        dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy, cx + Math.cos(hourAngle) * (radius * 0.5), cy + Math.sin(hourAngle) * (radius * 0.5)); 
    }
    function drawMinuteHand(dc as Dc, minute as Number) {
        var minAngle = (minute / 60.0) * 2 * Math.PI - Math.PI/2;
        var startR = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM) / 2;
        var endR = radius * 0.9;

        var x1 = cx + Math.cos(minAngle) * startR;
        var y1 = cx + Math.sin(minAngle) * startR;
        var x2 = cx + Math.cos(minAngle) * endR;
        var y2 = cx + Math.sin(minAngle) * endR;

        dc.setPenWidth(2);
        dc.setColor(HL, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1, x2, y2);
    }
    function drawMinuteHandPointer(dc as Dc, minute as Number) as Void {
        var a = (minute / 60.0) * 2 * Math.PI - Math.PI/2;

        // Where the chevron sits (near the edge)
        var tipR   = radius - 9;
        var wingR  = radius - 19; 
        var wingW  = 10.0;

        var tipX = cx + Math.cos(a) * tipR;
        var tipY = cy + Math.sin(a) * tipR;

        // Unit perpendicular to the radial angle
        var px = -Math.sin(a);
        var py =  Math.cos(a);

        // Base center (inward from tip)
        var baseX = cx + Math.cos(a) * wingR;
        var baseY = cy + Math.sin(a) * wingR;

        // Two wing endpoints
        var leftX  = baseX + px * wingW;
        var leftY  = baseY + py * wingW;
        var rightX = baseX - px * wingW;
        var rightY = baseY - py * wingW;

        // Optional rounding
        tipX = Math.round(tipX);   tipY = Math.round(tipY);
        leftX = Math.round(leftX); leftY = Math.round(leftY);
        rightX = Math.round(rightX); rightY = Math.round(rightY);

        dc.setColor(HL, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(leftX, leftY, tipX, tipY);
        dc.drawLine(rightX, rightY, tipX, tipY);
    }
    function drawSecondHand(dc as Dc, second as Number) {
        var secAngle = (second / 60.0) * 2 * Math.PI - Math.PI/2;
        var startR = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM) / 2;
        var endR = radius * 0.9;

        var x1 = cx + Math.cos(secAngle) * startR;
        var y1 = cx + Math.sin(secAngle) * startR;
        var x2 = cx + Math.cos(secAngle) * endR;
        var y2 = cx + Math.sin(secAngle) * endR;

        dc.setPenWidth(1);
        dc.setColor(SEC, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1, y1, x2, y2);
    }
    function formatTime(h as Number, m as Number) as String {
        var hour = h % 12;
        if (hour == 0) { hour = 12; }

        var minStr = (m < 10) ? ("0" + m) : m.toString();
        return hour + ":" + minStr;
    }
    function drawDateString(dc as Dc) {
        // Where to draw date
        // var x = cx * 1.5;
        var x = cx * 1.6;
        var y = cy;

        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var day_of_week = now.day_of_week;
        var month = now.month;
        var day = now.day;

        //var dateStr = (day_of_week + ", " + month + " " + day);       
        var dateStr = (day_of_week + " " + day);       
        var textHeight = dc.getFontHeight(Graphics.FONT_XTINY);

        dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - textHeight / 2, Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
    }
    function drawClasses(dc as Dc) {
        // Where to draw classes
        var x = cx;
        var y = cy * 1.3;
        var lineH = 20; // How far to separate lines

        var now = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var day_of_week = now.day_of_week;

        var classes = ClassSchedule.getClassesForDow(day_of_week);

        if (classes.size() == 0) {
            return;
        }

        for (var i = 0; i < classes.size(); i++) {
            var c = classes[i];
            var start = c[:start]; // [h, m]
            var end   = c[:end];
            var loc   = c[:loc];

            var timeStr = formatTime(start[0], start[1]) + "-" + formatTime(end[0], end[1]);
            var line = c[:title] + " / " + timeStr + " / " + loc;

            dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x, y, Graphics.FONT_XTINY, line, Graphics.TEXT_JUSTIFY_CENTER);
            y += lineH;
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    // Draw inward trangles at every 10 min mark
    function drawHexagonalTicks(dc as Dc, minute as Number) as Void {
        for (var i = 0; i <= minute; i += 1) {
            var angle = (i / 60.0) * 2 * Math.PI - Math.PI/2;

            var isMajor = (i % 5 == 0);
            var isCardinal = (i % 10 == 0);

            if (isCardinal) {    
                var tipLen  = 9.0;  // how far the tip sits inside from bezel
                var baseHalf = 6.0; // half-width of triangle base

                // Base center at bezel
                var baseCx = cx + Math.cos(angle) * radius;
                var baseCy = cy + Math.sin(angle) * radius;

                // Tip inward from bezel
                var tipR  = radius - tipLen;
                var tipX  = cx + Math.cos(angle) * tipR;
                var tipY  = cy + Math.sin(angle) * tipR;

                // Perpendicular for base endpoints (centered on bezel)
                var px = -Math.sin(angle);
                var py =  Math.cos(angle);

                var b1x = baseCx + px * baseHalf;
                var b1y = baseCy + py * baseHalf;
                var b2x = baseCx - px * baseHalf;
                var b2y = baseCy - py * baseHalf;

                // (Optional) rounding for better rendering on my Tactix 7
                tipX = Math.round(tipX); tipY = Math.round(tipY);
                b1x  = Math.round(b1x);  b1y  = Math.round(b1y);
                b2x  = Math.round(b2x);  b2y  = Math.round(b2y);

                dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
                dc.fillPolygon([[tipX, tipY], [b1x, b1y], [b2x, b2y]]);
            } else {
                var rOuter = radius;
                var rInner = isMajor ? (radius - 10) : (radius - 5);

                var xOuter = cx + Math.cos(angle) * rOuter;
                var yOuter = cy + Math.sin(angle) * rOuter;
                var xInner = cx + Math.cos(angle) * rInner;
                var yInner = cy + Math.sin(angle) * rInner;

                dc.setPenWidth(1);
                dc.setColor(isMajor ? FG : 0x666666, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(xInner, yInner, xOuter, yOuter);
            }
        }
    }

    // Draw inward pointing triangles at 12, 3, 6, and 9 instead
    function drawCardinalTicks(dc as Dc) {
        for (var i = 0; i <= 60; i += 15) {
            var angle = (i / 60.0) * 2 * Math.PI - Math.PI/2;
            var tipLen  = 9.0;  // how far the tip sits inside from bezel
            var baseHalf = 6.0; // half-width of triangle base

            // Base center at bezel
            var baseCx = cx + Math.cos(angle) * radius;
            var baseCy = cy + Math.sin(angle) * radius;

            // Tip inward from bezel
            var tipR  = radius - tipLen;
            var tipX  = cx + Math.cos(angle) * tipR;
            var tipY  = cy + Math.sin(angle) * tipR;

            // Perpendicular for base endpoints (centered on bezel)
            var px = -Math.sin(angle);
            var py =  Math.cos(angle);

            var b1x = baseCx + px * baseHalf;
            var b1y = baseCy + py * baseHalf;
            var b2x = baseCx - px * baseHalf;
            var b2y = baseCy - py * baseHalf;

            // (Optional) round for better rendering on my Tactix 7
            tipX = Math.round(tipX); tipY = Math.round(tipY);
            b1x  = Math.round(b1x);  b1y  = Math.round(b1y);
            b2x  = Math.round(b2x);  b2y  = Math.round(b2y);

            dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon([[tipX, tipY], [b1x, b1y], [b2x, b2y]]);
        }
    }
}
