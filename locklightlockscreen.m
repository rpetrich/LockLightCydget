#define CHAppName "LockLight"

#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit-Private.h>
#import <SpringBoard/SpringBoard.h>

static UIWindow *whiteWindow;
static float previousBacklight;

CHDeclareClass(SBAwayController)
CHDeclareClass(SBAwayViewPluginController)
CHDeclareClass(UITapGestureRecognizer)

CHClassMethod0(id, LockLightController, rootViewController)
{
	return [[[self alloc] init] autorelease];
}

CHMethod0(void, LockLightController, loadView)
{
	CHSuper0(LockLightController, loadView);
	if (!whiteWindow) {
		// Show Window
		whiteWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		[whiteWindow setBackgroundColor:[UIColor whiteColor]];
		[whiteWindow makeKeyAndVisible];
		[whiteWindow setWindowLevel:1102.0f];
		// Add Gesture Recognizer
		UITapGestureRecognizer *tapGesture = [CHAlloc(UITapGestureRecognizer) initWithTarget:self action:@selector(killWhiteWindow)];
		[whiteWindow addGestureRecognizer:tapGesture];
		[tapGesture release];
		// Get Previous Backlight
		NSDictionary *springboardSettings = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.apple.springboard.plist"];
		id setting = [springboardSettings objectForKey:@"SBBacklightLevel2"];
		if (setting)
			previousBacklight = [setting floatValue];
		else {
			setting = [springboardSettings objectForKey:@"SBBacklightLevel"];
			if (setting)
				previousBacklight = [setting floatValue];
			else
				previousBacklight = 0.5f;
		}
		// Set Backlight
		[(id)[UIApplication sharedApplication] setBacklightLevel:1.0f];
		// Disable dim timer
		[[CHClass(SBAwayController) sharedAwayController] cancelDimTimer];
	}
}

CHMethod1(void, LockLightController, viewDidDisappear, BOOL, animated)
{
	CHSuper1(LockLightController, viewDidDisappear, animated);
	[self killWhiteWindow];
}

CHMethod0(void, LockLightController, killWhiteWindow)
{
	if (whiteWindow != nil) {
		// Hide Window
		[whiteWindow setHidden:YES];
		[whiteWindow release];
		whiteWindow = nil;
		// Return Backlight to previous state
		id app = [UIApplication sharedApplication];
		[app setBacklightLevel:previousBacklight];
		[app turnOffBacklightAfterDelay];
	}
}

CHConstructor
{
	CHLoadLateClass(SBAwayController);
	CHLoadLateClass(SBAwayViewPluginController);
	CHLoadLateClass(UITapGestureRecognizer);
	CHRegisterClass(LockLightController, SBAwayViewPluginController) {
		CHClassHook0(LockLightController, rootViewController);
		CHHook0(LockLightController, loadView);
		CHHook1(LockLightController, viewDidDisappear);
	}
	CHHook0(LockLightController, killWhiteWindow);
}