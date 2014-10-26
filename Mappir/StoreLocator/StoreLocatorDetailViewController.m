

#import "StoreLocatorDetailViewController.h"
#import "StoreLocation.h"
#import "StoreAnnotation.h"

@implementation StoreLocatorDetailViewController
@synthesize storeImageView;
@synthesize storeNameLabel;
@synthesize storeAddressLabel;
@synthesize distanceLabel;
@synthesize location;
@synthesize userLocationAddressLabel;
@synthesize serviceHours;
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithLocation:(StoreLocation *)aLocation delegate:(id<StoreLocatorDetailDelegate>)_delegate{

    self = [super initWithNibName:@"StoreLocatorDetailViewController" bundle:nil];
    if (self) {
        self.location = aLocation;
        self.delegate = _delegate;
    }
    return self;
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [self getButtonFromType:SuperiorBarButtonBack];
    [button addTarget:self action:@selector(popNavigationViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* br = [[UIBarButtonItem alloc] initWithCustomView:button];
    //[buttons addObject:br];
    [self.navigationItem setLeftBarButtonItem:br animated:YES];
    StoreType type = [StoreAnnotation getTypeFromLocationType:location.type];
    self.storeNameLabel.text = [NSString stringWithFormat:@"%@ %@", [StoreAnnotation getStoreNameFromType:type], location.storeName];
    self.storeAddressLabel.text = self.location.storeAddress;
    self.storeImageView.image = [StoreAnnotation getImageFromType:type];
    self.serviceHours.text = self.location.storeSchedule;
    if (self.location.distanceInMeters > 500) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f km",(self.location.distanceInMeters/1000)];
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%d m",(int)self.location.distanceInMeters];
    }
}

- (void)dealloc
{
    self.location = nil;
    self.storeNameLabel = nil;
    self.storeAddressLabel = nil;
    self.storeImageView = nil;
    self.serviceHours = nil;
    self.distanceLabel = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)routeButtonPressed:(id)sender {
    UIButton *button = sender;
    if ([self.delegate respondsToSelector:@selector(StoreLocatorDetail:GetRouteWithType:)]){
        [self.delegate StoreLocatorDetail:self GetRouteWithType:[button tag]];
        [self popNavigationViewControllerAnimated];
    }
}

@end
