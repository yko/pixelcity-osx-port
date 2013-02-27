//
//  PixelCityViewController.h
//  PixelCity
//
//  Created by Patrick Wallace on 24/02/2013.
//  Copyright (c) 2013 Patrick Wallace. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Render.h"

@interface PixelCityViewController : NSViewController <NSWindowDelegate>
{
    BOOL fAnimate, fDrawCaps, fDrawHelp;
	BOOL fWireframe, fLetterbox, fFPS, fFog, fFlat, fHelp, fNormalize;
    EffectType effect;
    NSTimer *timer;

    __weak IBOutlet NSMenuItem * animateMenuItem;
    __weak IBOutlet NSMenuItem * infoMenuItem;
    __weak IBOutlet NSMenuItem * resetMenuItem;
    __weak IBOutlet NSMenuItem * wireframeToggleMenuItem;
    __weak IBOutlet NSMenuItem * effectCycleMenuItem;
    __weak IBOutlet NSMenuItem * letterboxToggleMenuItem;
    __weak IBOutlet NSMenuItem * FPSToggleMenuItem;
    __weak IBOutlet NSMenuItem * fogToggleMenuItem;
    __weak IBOutlet NSMenuItem * flatToggleMenuItem;
    __weak IBOutlet NSMenuItem * helpToggleMenuItem;
    __weak IBOutlet NSMenuItem * normalizeToggleMenuItem;
    __weak IBOutlet NSMenuItem * debugLogToggleMenuItem;
}

    // Menu action events.
-(IBAction) animate:         (id) sender;
-(IBAction) info:            (id) sender;
-(IBAction) toggleWireframe: (id) sender;
-(IBAction) nextEffect:      (id) sender;
-(IBAction) toggleLetterbox: (id) sender;
-(IBAction) toggleFPS:       (id) sender;
-(IBAction) toggleFog:       (id) sender;
-(IBAction) toggleFlat:      (id) sender;
-(IBAction) toggleHelp:      (id) sender;
-(IBAction) toggleNormalized:(id) sender;
-(IBAction) toggleDebugLog:  (id) sender;
-(IBAction) resetWorld:      (id) sender;

@end
