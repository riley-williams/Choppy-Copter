//
//  MyScene.h
//  Choppy Copter
//

//  Copyright (c) 2014 Riley Williams. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate>
@property SKLabelNode *instructions;
@property SKSpriteNode *copter;
@property CGFloat pipeSpeed;
@property SKLabelNode *scoreLabel;
@property SKLabelNode *highScoreLabel;

@property int score;
@property int highScore;
@property BOOL isStarted;

-(void)addPipe;
-(void)addBackgroundObject;

@end
