//
//  DELaunchViewController.m
//  PinFever
//
//  Created by David Ehlen on 09.05.15.
//  Copyright (c) 2015 David Ehlen. All rights reserved.
//

#import "DELaunchViewController.h"
#import "PlayerCollectionViewCell.h"
#import "DECategoryViewController.h"
#import "DEPlayer.h"
#import "AppDelegate.h"

@interface DELaunchViewController ()
@property (nonatomic,strong) UIView *footerView;
@end

@implementation DELaunchViewController

#define FOOTER_HEIGHT 50
#define STARTBUTTON_HEIGHT 30
#define STARTBUTTON_WIDTH 60
#define STARTLABEL_HEIGHT 30

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"newGameTitle", nil);
    
    fileManager = [DEFileManager new];
    
    self.tagControl.tagPlaceholder = NSLocalizedString(@"tagPlaceholder", nil);
    self.tagControl.mode = TLTagsControlModeEdit;
    self.tagControl.tagDelegate = self;
    self.tagControl.maxTags = @1;
    [self setupFooterView];
    
    self.friendsAndRecent = [NSMutableArray new];
    [self loadFriends];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -
#pragma mark Methods
-(void)startGame {
    //Only 1 opponent is allowed therefore always tags[0]
    NSString *opponentName = [self.tagControl stringForTagIndex:0];
    NSLog(@"%@",opponentName);
    //TODO: Opponent mitübergeben
    DECategoryViewController *categoryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

-(void)setupFooterView {
    self.footerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, FOOTER_HEIGHT)];
    self.footerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin);
    self.footerView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.7];
    self.footerView.alpha = 0.0;
    
    UIButton *startButton = [[UIButton alloc]initWithFrame:CGRectMake(self.footerView.frame.size.width-STARTBUTTON_WIDTH-15, (FOOTER_HEIGHT-STARTBUTTON_HEIGHT)/2, STARTBUTTON_WIDTH, STARTBUTTON_HEIGHT)];
    UIColor *darkGrayColor = [UIColor colorWithRed:(CGFloat) (23.0 / 255.0) green:(CGFloat) (27.0 / 255.0) blue:(CGFloat) (34.0 / 255.0) alpha:1.0];
    startButton.backgroundColor = [UIColor clearColor];
    startButton.layer.borderColor = darkGrayColor.CGColor;
    startButton.layer.borderWidth = 1.0f;
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:darkGrayColor forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [startButton addTarget:self action:@selector(startGame) forControlEvents:UIControlEventTouchUpInside];
    startButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    startButton.layer.cornerRadius = 5;
    [self.footerView addSubview:startButton];
    
    UILabel *footerLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, (FOOTER_HEIGHT-STARTLABEL_HEIGHT)/2, 150, STARTLABEL_HEIGHT)];
    footerLabel.text = NSLocalizedString(@"pinFeverGame", nil);
    footerLabel.textColor = darkGrayColor;
    footerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [self.footerView addSubview:footerLabel];
    
    [self.view insertSubview:self.footerView aboveSubview:self.collectionView];
}

-(void)loadFriends {
    self.friendsAndRecent = [fileManager loadMutableArray:kFriendsFilename];
    DEPlayer *autoMatchPlayer = [DEPlayer new];
    autoMatchPlayer.playerId = @"";
    autoMatchPlayer.email = @"";
    autoMatchPlayer.displayName = NSLocalizedString(@"autoMatch", nil);
    autoMatchPlayer.level = [NSNumber numberWithInteger:-1];
    [self.friendsAndRecent insertObject:autoMatchPlayer atIndex:0];

}

#pragma mark -
#pragma mark UICollectionViewDataSource & Delegate

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.friendsAndRecent.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
    DEPlayer *player = self.friendsAndRecent[(NSUInteger)indexPath.row];
    cell.playerImageView.image = [UIImage imageNamed:@"avatarPlaceholder"];
    cell.playerNameLabel.text = player.displayName;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGAffineTransform expandTransform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:.4 initialSpringVelocity:.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        cell.transform = expandTransform;
    } completion:^(BOOL finished) {
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CGAffineTransform normalTransform = CGAffineTransformMakeScale(1.0, 1.0);
    cell.transform = CGAffineTransformInvert(normalTransform);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PlayerCollectionViewCell *cell = (PlayerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.tagControl addTag:cell.playerNameLabel.text];
    [self.tagControl reloadTagSubviews];
}

#pragma mark - TLTagsControlDelegate
- (void)tagsControl:(TLTagsControl *)tagsControl tappedAtIndex:(NSInteger)index {
    NSLog(@"Tag \"%@\" was tapped", tagsControl.tags[(NSUInteger) index]);
}

-(void)showFooter {
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.footerView.alpha = 1.0;
        CGRect footerFrame = self.footerView.frame;
        footerFrame.origin.y = footerFrame.origin.y-FOOTER_HEIGHT;
        self.footerView.frame = footerFrame;

    } completion:nil];
}

-(void)hideFooter {
    
    [UIView animateWithDuration:0.7 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.footerView.alpha = 0.0;
        CGRect footerFrame = self.footerView.frame;
        footerFrame.origin.y = footerFrame.origin.y+FOOTER_HEIGHT;
        self.footerView.frame = footerFrame;
        
    } completion:nil];
}


@end
