//
//  ViewController.m
//  VectorMapTest
//
//  Created by Nikita on 18.10.13.
//
//

#import "ViewController.h"
#import "RMMapView.h"
#import "RMOSPTileSource.h"
#import "RMTileSource.h"

@interface ViewController ()

@end

@implementation ViewController

NSString * dbkey = @"supersecretkey2";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)interfaceOrientationIsPortrait
{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

- (CGRect)getDisplayBoundsInCurrentOrientationMode
{
    if([self interfaceOrientationIsPortrait])
        return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    else
        return CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
}

-(void) viewDidAppear:(BOOL)animated
{
	CLLocationCoordinate2D startingPoint = CLLocationCoordinate2DMake(55.754529,37.625224);
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"moscow" ofType:@"map"];
    
    
    RMOSPTileSource * tileSource = [[RMOSPTileSource alloc] initWithMapFile:filePath andBuilding:0 andFloorlevel:0];

    CGRect rect = [self getDisplayBoundsInCurrentOrientationMode];
    
    RMMapView * offlineMap = [[RMMapView alloc] initWithFrame:rect andTilesource:tileSource];
    
    [offlineMap setCenterCoordinate:startingPoint];
    [offlineMap setTileSource:tileSource];
    
    [offlineMap setMinZoom:19];
    [offlineMap setMaxZoom:26];
    [offlineMap setZoom:18];
    [offlineMap setDraggingEnabled:YES];
    
    
    NSLog(@"Applied Tile Source to the Map - Finished loading.");
    
    [self.view addSubview:offlineMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
