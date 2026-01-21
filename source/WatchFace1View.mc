import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

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
        drawActiveHour(dc, hour);

        // Hands
        drawHourHand(dc, hour, minute);
        drawMinuteHand(dc, minute);
        drawSecondHand(dc, second);
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
    function drawHourHand(dc as Dc, hour as Number, minute as Number) {
        var hourAngle = ((hour + minute / 60.0) / 12.0) * 2 * Math.PI - Math.PI/2;
        dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy, cx + Math.cos(hourAngle) * (radius * 0.5), cy + Math.sin(hourAngle) * (radius * 0.5)); 
    }
    function drawMinuteHand(dc as Dc, minute as Number) {
        var minAngle = (minute / 60.0) * 2 * Math.PI - Math.PI/2;
        dc.setColor(FG, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy, cx + Math.cos(minAngle) * (radius * 0.8), cy + Math.sin(minAngle) * (radius * 0.8));
    }
    function drawSecondHand(dc as Dc, second as Number) {
        var secAngle = (second / 60.0) * 2 * Math.PI - Math.PI/2;
        dc.setColor(SEC, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx, cy, cx + Math.cos(secAngle) * (radius * 0.9), cy + Math.sin(secAngle) * (radius * 0.9)); 
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
