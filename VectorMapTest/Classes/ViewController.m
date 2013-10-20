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

	CLLocationCoordinate2D startingPoint = CLLocationCoordinate2DMake(55.754529,37.625224);
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"moscow" ofType:@"map"];
	
	RMMapView *offlineMap = [RMMapView mapViewWithFrame:self.view.frame
												   file:filePath
											 startPoint:startingPoint
												   zoom:16
												maxZoom:20
												minZoom:10];
	
	[self.view addSubview:offlineMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
