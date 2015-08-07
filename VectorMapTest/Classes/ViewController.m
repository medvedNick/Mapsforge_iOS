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
    float aspect_x,aspect_y;
    if (rect.size.width < rect.size.height) {
        aspect_x = 0.3 + rect.size.height / rect.size.width;
        aspect_y =  0.7 + rect.size.width / rect.size.height;
    } else {
        aspect_x = 0.7 + rect.size.height / rect.size.width;
        aspect_y =  0.3 + rect.size.width / rect.size.height;
    }
    rect.origin.x = 0 - (((rect.size.width * aspect_x) - rect.size.width) / 2);
    rect.origin.y = 0 - (((rect.size.height * aspect_y) - rect.size.height) / 2);
    rect.size.width = rect.size.width * aspect_x;
    rect.size.height = rect.size.height * aspect_y;
    
    RMMapView * offlineMap = [[RMMapView alloc] initWithFrame:rect andTilesource:tileSource];
    
    [offlineMap setCenterCoordinate:startingPoint];
    [offlineMap setTileSource:tileSource];
    
    [offlineMap setMinZoom:10];
    [offlineMap setMaxZoom:26];
    [offlineMap setZoom:18];
    [offlineMap setDraggingEnabled:YES];
    [offlineMap setCenterCoordinate: CLLocationCoordinate2DMake(55.754529,37.625224)];
    
    NSLog(@"Applied Tile Source to the Map - Finished loading.");
    
    [self.view addSubview:offlineMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
