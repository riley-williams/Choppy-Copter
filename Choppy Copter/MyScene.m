//
//  MyScene.m
//  Choppy Copter
//
//  Created by Riley Williams on 2/2/14.
//  Copyright (c) 2014 Riley Williams. All rights reserved.
//

#import "MyScene.h"

#define k_jump_velocity (CGVector){0,5}
#define k_copter_x 85

const u_int32_t copterCategory		= 0x1 << 0;
const u_int32_t pipeCategory		= 0x1 << 1;
const u_int32_t groundCategory		= 0x1 << 2;
const u_int32_t powerUpCategory		= 0x1 << 3;
const u_int32_t backgroundCategory	= 0x1 << 4;
const u_int32_t brokenPipeCategory	= 0x1 << 5;

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.6 green:0.8 blue:1.0 alpha:1.0];
		self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
		self.physicsBody.restitution = 0.0;
		self.physicsBody.categoryBitMask = groundCategory;
		self.physicsBody.collisionBitMask = copterCategory;
		self.physicsWorld.gravity = CGVectorMake(0, -9.8);
		self.physicsWorld.contactDelegate = self;
		
        self.instructions = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Bold"];
        self.instructions.text = @"Tap to fly";
        self.instructions.fontSize = 30;
        self.instructions.position = CGPointMake(CGRectGetMidX(self.frame)+15, CGRectGetMidY(self.frame));
        [self addChild:self.instructions];
		
		self.score = -2;
		self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Bold"];
		self.scoreLabel.text = @"0";
		self.scoreLabel.fontSize = 35;
		self.scoreLabel.fontColor = [UIColor blackColor];
		self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 60);
		self.scoreLabel.zPosition = 100;
		[self addChild:self.scoreLabel];
		
		self.highScore = 0;
		self.highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
		self.highScoreLabel.text = @"Max: 0";
		self.highScoreLabel.fontSize = 15;
		self.highScoreLabel.fontColor = [UIColor blackColor];
		self.highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 90);
		self.highScoreLabel.zPosition = 100;
		[self addChild:self.highScoreLabel];

		
		self.isStarted = NO;
		
		self.copter = [SKSpriteNode spriteNodeWithImageNamed:@"Copter"];
		self.copter.size = CGSizeMake(50, 35);
		self.copter.position = CGPointMake(k_copter_x, 300);
		self.copter.physicsBody.restitution = 0.25;
		self.copter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.copter.frame.size];
		self.copter.physicsBody.categoryBitMask		= copterCategory;
		self.copter.physicsBody.collisionBitMask	= groundCategory | pipeCategory;
		self.copter.physicsBody.contactTestBitMask	= powerUpCategory | pipeCategory;
		self.copter.physicsBody.allowsRotation = NO;
		self.copter.physicsBody.affectedByGravity = NO;
		self.pipeSpeed = 115;
		
		[self addChild:self.copter];
		
		NSTimer *cloudAdder = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(addBackgroundObject) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:cloudAdder forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!self.isStarted) {
		[self.instructions removeFromParent];
		self.isStarted = YES;
		self.copter.physicsBody.affectedByGravity = YES;
		NSTimer *pipeAdder = [NSTimer timerWithTimeInterval:1.5f target:self selector:@selector(addPipe) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:pipeAdder forMode:NSRunLoopCommonModes];
	}
	
	self.copter.physicsBody.velocity = CGVectorMake(0, 400);
}

-(void)update:(CFTimeInterval)currentTime {
	self.copter.zRotation = self.copter.physicsBody.velocity.dy/1250;
	self.copter.position = CGPointMake(k_copter_x, self.copter.position.y);
}


-(void)addPipe {
	//update score
	self.score++;
	if (self.score > 0) {
		self.scoreLabel.text = [NSString stringWithFormat:@"%i",self.score];
		if (self.score > self.highScore) {
			self.highScore = self.score;
			self.highScoreLabel.text = [NSString stringWithFormat:@"Max: %i",self.highScore];
		}
	} else {
		self.scoreLabel.text = @"0";
	}
	
	SKSpriteNode *topHalf = [SKSpriteNode spriteNodeWithImageNamed:@"Pipe"];
	CGFloat yPos = self.view.frame.size.height - arc4random_uniform(175);
	topHalf.position = CGPointMake(400, yPos);
	topHalf.size = CGSizeMake(55, 325);
	topHalf.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topHalf.frame.size];
	topHalf.physicsBody.affectedByGravity = NO;
	topHalf.physicsBody.velocity = CGVectorMake(-self.pipeSpeed, 0);
	topHalf.physicsBody.categoryBitMask = pipeCategory;
	topHalf.physicsBody.collisionBitMask = copterCategory | brokenPipeCategory;
	topHalf.physicsBody.contactTestBitMask = copterCategory | brokenPipeCategory;
	topHalf.physicsBody.friction = 0.0f;
	topHalf.physicsBody.linearDamping = 0.0f;
	topHalf.physicsBody.mass = 0.01f;
	topHalf.physicsBody.restitution = 0.1f;
	topHalf.zRotation = M_PI;
	[self addChild:topHalf];
	SKSpriteNode *bottomHalf = [SKSpriteNode spriteNodeWithImageNamed:@"Pipe"];
	bottomHalf.position = CGPointMake(400, yPos-topHalf.size.height - 125);
	bottomHalf.size = CGSizeMake(55, 325);
	bottomHalf.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomHalf.frame.size];
	bottomHalf.physicsBody.affectedByGravity = NO;
	bottomHalf.physicsBody.velocity = CGVectorMake(-self.pipeSpeed, 0);
	bottomHalf.physicsBody.categoryBitMask = pipeCategory;
	bottomHalf.physicsBody.collisionBitMask = copterCategory | brokenPipeCategory;
	bottomHalf.physicsBody.contactTestBitMask = copterCategory | brokenPipeCategory;
	bottomHalf.physicsBody.friction = 0.0f;
	bottomHalf.physicsBody.linearDamping = 0.0f;
	bottomHalf.physicsBody.mass = 0.01f;
	bottomHalf.physicsBody.restitution = 0.1f;
	[self addChild:bottomHalf];

}

-(void)addBackgroundObject {
	SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"Cloud"];
	CGFloat yPos = self.view.frame.size.height+10-arc4random_uniform(150);
	cloud.position = CGPointMake(500, yPos);
	CGFloat size = (arc4random_uniform(16)+5)/16.0f;
	CGFloat zPos = (float)arc4random_uniform(5)-2;
	cloud.size = CGSizeMake(256*size, 256*size);
	cloud.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cloud.frame.size];
	cloud.physicsBody.affectedByGravity = NO;
	cloud.physicsBody.velocity = CGVectorMake(-self.pipeSpeed-zPos*15, 0);
	cloud.physicsBody.categoryBitMask = backgroundCategory;
	cloud.physicsBody.collisionBitMask = 0x0;
	cloud.physicsBody.contactTestBitMask = 0x0;
	cloud.physicsBody.linearDamping = 0.0f;
	cloud.zPosition = zPos;
	cloud.alpha = 0.65;
	cloud.blendMode = SKBlendModeScreen;
	[self addChild:cloud];
	
	SKSpriteNode *mountain = [SKSpriteNode spriteNodeWithImageNamed:@"Mountain"];
	CGFloat msize = (arc4random_uniform(16)+5)/16.0f;
	CGFloat mzPos = -(float)arc4random_uniform(5)-1;
	mountain.size = CGSizeMake(256*msize, 256*msize);
	mountain.position = CGPointMake(500, mountain.frame.size.height/2);
	mountain.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:mountain.frame.size];
	mountain.physicsBody.affectedByGravity = NO;
	mountain.physicsBody.velocity = CGVectorMake(-self.pipeSpeed-mzPos*15, 0);
	mountain.physicsBody.categoryBitMask = backgroundCategory;
	mountain.physicsBody.collisionBitMask = 0x0;
	mountain.physicsBody.contactTestBitMask = 0x0;
	mountain.physicsBody.linearDamping = 0.0f;
	mountain.zPosition = mzPos;
	[self addChild:mountain];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
	self.score = -1;
	self.scoreLabel.text = @"0";
	if (contact.bodyA.node.physicsBody.categoryBitMask == pipeCategory) {
		contact.bodyA.node.physicsBody.affectedByGravity = YES;
		contact.bodyA.node.physicsBody.categoryBitMask = brokenPipeCategory;
		contact.bodyA.node.physicsBody.collisionBitMask = brokenPipeCategory;
	}
	if (contact.bodyB.node.physicsBody.categoryBitMask == pipeCategory) {
		contact.bodyB.node.physicsBody.affectedByGravity = YES;
		contact.bodyB.node.physicsBody.categoryBitMask = brokenPipeCategory;
		contact.bodyB.node.physicsBody.collisionBitMask = brokenPipeCategory;
	}
}

@end
