//
//  Instrument.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "Instrument.h"
#import "SimpleAudioEngine.h"
#import "cocos2d.h"

@implementation Instrument
@synthesize tempo, pitch, gain, numberOfNotes, delegate, selector;

-(void)dealloc
{
	[name release];
	[super dealloc];
}

-(id)initWithName: (NSString *)n numberOfNotes: (int)numNotes tempo: (NSTimeInterval)tmpo
{
	if ((self = [super init]))
	{
		name = [n retain];
		numberOfNotes = numNotes;
		tempo = tmpo;
		pitch = 1.0f;
		gain = 0.3f;
		delegate = nil;
		selector = nil;
	}
	return self;
}

+(id)instrumentWithName: (NSString *)n numberOfNotes: (int)numNotes tempo: (NSTimeInterval)tmpo
{
	return [[[self alloc] initWithName: n numberOfNotes: numNotes tempo: tmpo] autorelease];
}

-(void)playSequence: (NSString *)seq
{
//	NSMutableArray *actions = [[[NSMutableArray alloc] initWithCapacity: 255] autorelease];
	
	CCLOG(@"Generating action sequence for seq: \"%@\"", seq);
	
	int iterator = 0;
	for (NSString *str in [seq componentsSeparatedByString: @","])
	{
		if (![str isEqualToString: @" "])
		{
			int note = [str intValue];
			NSLog(@"NOTE IS %d", note);
			[self performSelector: @selector(playNoteNumber:) withObject: [NSNumber numberWithInteger: note] afterDelay: iterator * tempo];
		}
		iterator++;
	}
	
//	for (NSString *str in [seq componentsSeparatedByString: @","])
//	{
//		if ([str isEqualToString: @" "])
//			[actions addObject: [CCDelayTime actionWithDuration: tempo]];
//		else
//		{
//			int note = [str intValue];
//			NSLog(@"Adding note %d", note);
//			[actions addObject: [CCCallFuncND actionWithTarget: self selector: @selector(playNote:) data: note]];
//			[actions addObject: [CCDelayTime actionWithDuration: tempo]];
//		}
//	}
//	
//	id action = [Instrument actionMutableArray: actions];
//	NSLog([action description]);
//	[self runAction: action];
}

-(void)playNote:(int)note
{
	CCLOG(@"Playing note %d", note);
	
	if (note > numberOfNotes)
		CCLOG(@"Warning, note index %d out of bounds", note);
	
	[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%@%d.wav", name, note] pitch: pitch pan:0.0f gain: gain];
	
	if (delegate)
	{
		if ([delegate respondsToSelector: selector])
			[delegate performSelector: selector withObject: [NSNumber numberWithInt: note]];
		else
			NSLog(@"Delegate %@ does not respond to selector", [delegate description]);
	}
}

-(void)playChord:(NSString *)chordStr
{
	for (NSString *str in [chordStr componentsSeparatedByString:@","])
	{
		int note = [str intValue];
		[self playNote: note];
	}
}
		 
-(void)playNoteNumber: (NSNumber *)num
{
	CCLOG(@"PLAY NOTE NUMBER %d", [num intValue]);
	[self playNote: [num integerValue]];
}

+(CCFiniteTimeAction *)getActionSequence: (NSArray *) actions
{
	CCFiniteTimeAction *seq = nil;
	for (CCFiniteTimeAction *anAction in actions)
	{
		if (!seq)
		{
			seq = anAction;
		}
		else
		{
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}
	return seq;
}

+(id) actionMutableArray: (NSMutableArray*) _actionList {
	CCFiniteTimeAction *now;
	CCFiniteTimeAction *prev = [_actionList objectAtIndex:0];
	
	for (int i = 1 ; i < [_actionList count] ; i++) {
		now = [_actionList objectAtIndex:i];
		prev = [CCSequence actionOne: prev two: now];
	}
	
	return prev;
}

+(float)bluesPitchForIndex: (int)index
{
	float pitches[] = { 1.0, 0.891, 0.75, 0.707, 0.665, 0.595, 0.5 };
	return pitches[index];
}


@end
