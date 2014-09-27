//
//  StoreLocatorConfigurationViewController.m
//  WalmartApp
//
//  Created by WALMEX3.0_1_WALMART on 06/10/11.
//  Copyright 2011 Walmart Stores Inc. All rights reserved.
//

#import "StoreLocatorConfigurationViewController.h"
#import "StoreAnnotation.h"
#import "StoreLocation.h"
//#import "WEPopoverController.h"
#import "Definitions.h"


@implementation StoreLocatorConfigurationViewController
@synthesize dataSource;
@synthesize enabledFilters;
@synthesize type;
@synthesize delegate;
@synthesize popoverController;
@synthesize nearStoresTableView;
@synthesize directionsTableView;
@synthesize nearView;
@synthesize directionsView;
@synthesize extraInfo;
@synthesize storesLabel;
@synthesize distanceLabel;
@synthesize distanceTimeLabel;
@synthesize distanceSlider;
@synthesize storesSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithType:(TableType)_type dataSource:(NSArray*)_dataSource selectedItems:(NSIndexSet*)selItems delegate:(id<StoreLocationConfigurationDelegate>)_delegate
{
    self = [self initWithNibName:@"StoreLocatorConfigurationViewController" bundle:nil];
    if (self) {
        // Custom initialization
        type = _type;
        self.delegate = _delegate;
        CGSize size = CGSizeZero;
        [self setDataSource:_dataSource];
        self.enabledFilters = [NSMutableIndexSet indexSet];
        if (selItems)
            [self.enabledFilters addIndexes:selItems];

//        switch(type) {
//            case TableTypeNearMe:
//            {
//                if ([self.dataSource count] > 3) {
//                    size = CGSizeMake(280, 88*3);
//                }  else {
//                    size = CGSizeMake(280, 88*[self.dataSource count]);
//                }
//            }
//                break;
//            case TableTypeStoresCatalog:
//            {
//                if ([self.dataSource count] > 5) {
//                    size = CGSizeMake(280, 50*5);
//                }  else {
//                    size = CGSizeMake(280, 50*[self.dataSource count]);
//                }
//            }
//                break;
//            case TableTypeDirections:
//            {
//                if ([self.dataSource count] > 6) {
//                    size = CGSizeMake(280, 60*5);
//                }  else {
//                    size = CGSizeMake(280, 60*[self.dataSource count]);
//                }
//            }
//                break;
//            case TableTypeConfiguration:
//            {
//                size = CGSizeMake(200, 50*4);
//            }
//                break;
//        }
//        size.height += (44+22);
//        self.contentSizeForViewInPopover = size;
        
    }
    return self;
}

- (void)dealloc
{
    self.enabledFilters = nil;
    self.dataSource = nil;
    self.extraInfo = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect superviewFrame = self.view.superview.frame;
    CGSize superviewSize = superviewFrame.size;
    superviewSize.height -= 44;
    CGRect frame = self.view.frame;
    CGPoint destination = CGPointZero;
    destination.y = (superviewSize.height - frame.size.height) / 2;
    destination.x = superviewSize.width + 10;
    frame.origin = destination;
    
    if (self.type == TableTypeConfiguration) {
        NSNumber *distanceConfig = [self.extraInfo objectForKey:@"currentDistance"];
        self.distanceSlider.value = [distanceConfig intValue];
        [self sliderChanged:self.distanceSlider];
        NSNumber *currentStores = [self.extraInfo objectForKey:@"currentMaxStores"];
        self.storesSlider.value = [currentStores intValue];
        [self sliderChanged:self.storesSlider];
    } else {
        self.distanceTimeLabel.text = [NSString stringWithFormat:@"%@, %@", [extraInfo objectForKey:@"distance"], [extraInfo objectForKey:@"duration"]];
    }
    
    self.view.frame = frame;
    self.view.hidden = NO;
    [self show];
    
    
}


- (void)show {
    CGRect superviewFrame = self.view.superview.frame;
    CGSize superviewSize = superviewFrame.size;
    CGRect frame = self.view.frame;
    [UIView beginAnimations:@"show" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    frame.origin.x = (superviewSize.width - frame.size.width) / 2;
    self.view.frame = frame;
    [UIView commitAnimations];
    
}

- (void)dismiss {
    CGRect frame = self.view.frame;
    CGRect superviewFrame = self.view.superview.frame;
    CGSize superviewSize = superviewFrame.size;    
    [UIView beginAnimations:@"dismiss" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationDuration:0.2];
    frame.origin.x = - superviewSize.width;
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)dismissFromScreen {
    CGRect frame = self.view.frame;
    CGRect superviewFrame = self.view.superview.frame;
    CGSize superviewSize = superviewFrame.size;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    frame.origin.x = - superviewSize.width;
    self.view.frame = frame;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"dismiss"]) {
        if ([delegate respondsToSelector:@selector(configViewControllerDidDismiss:)])
        {
            [self.view removeFromSuperview];
            [delegate configViewControllerDidDismiss:self];
        }
    } else if ([animationID isEqualToString:@"show"]) {
        if ([delegate respondsToSelector:@selector(configViewControllerDidShow:)])
        {
            [delegate configViewControllerDidShow:self];
        }
    }
}




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (self.type == TableTypeDirections) {
        self.nearView.hidden = YES;
        self.directionsView.hidden = NO;
    }
    else if (self.type == TableTypeConfiguration) {
        self.nearView.hidden = NO;
        self.directionsView.hidden = YES;
    }
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

- (void)setDataSource:(NSArray*)array {
    dataSource = [NSArray arrayWithArray:array];
    if (self.type == TableTypeDirections) {
        self.nearStoresTableView.delegate = nil;
        self.nearStoresTableView.dataSource = nil;

        [self.directionsTableView reloadData];
    } else {
        self.directionsTableView.delegate = nil;
        self.directionsTableView.dataSource = nil;

        [self.nearStoresTableView reloadData];
    }
}
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.type == TableTypeStoresCatalog) {
        return [self.dataSource count];
    } else if (self.type == TableTypeNearMe || self.type == TableTypeConfiguration) {
        if ([self.dataSource count] == 0) 
            return 1;
        else
        return [self.dataSource count];
    } else if (self.type == TableTypeDirections) {
        return [self.dataSource count];
    } 
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Identifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    UIImageView *bgView = nil;
    UIImageView *selBgView = nil;
    if (!cell) {
        if (self.type == TableTypeStoresCatalog) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barraNegocio@2x.png"]];
            selBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barraNegocio_press@2x.png"]];
        } else if (self.type == TableTypeNearMe || self.type == TableTypeConfiguration){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barra_tiendaCercana.png"]];
            selBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barra_tiendaCercana_press.png"]];
            [cell.textLabel setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setNumberOfLines:0];
            [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
            [cell.textLabel setTextColor:[UIColor colorWithRGBValue:0x5d5d5d]];
            [cell.detailTextLabel setTextColor:[UIColor colorWithRGBValue:0x5d5d5d]];
            UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flecha_objeto_lista_tiendas.png"] highlightedImage:[UIImage imageNamed:@"flecha_objeto_lista_tiendas_press"]];
            [cell setAccessoryView:arrow];
//            UILabel *distanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(60.0, 70.0, 150.0, 15.0)] autorelease];
//            [distanceLabel setBackgroundColor:[UIColor clearColor]];
//            [distanceLabel setFont:[UIFont boldSystemFontOfSize:12]];
//            [distanceLabel setTag:5];
//            [[cell contentView] addSubview:distanceLabel];
        } else if (self.type == TableTypeDirections) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barra_tiendaCercana.png"]];
            selBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barra_tiendaCercana_press.png"]];
            
#if DIRECTIONS_FORMAT == 0
            UILabel *directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 220, 60)];
            [directionLabel setBackgroundColor:[UIColor clearColor]];
            [directionLabel setFont:[UIFont systemFontOfSize:12]];
            [directionLabel setTag:5];
            [directionLabel setNumberOfLines:5];
            [directionLabel setAdjustsFontSizeToFitWidth:YES];
            UILabel *distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 0, 50, 60)];
            [distanceLabel setBackgroundColor:[UIColor clearColor]];
            [distanceLabel setFont:[UIFont boldSystemFontOfSize:10]];
            [distanceLabel setTextAlignment:UITextAlignmentRight];
            [distanceLabel setTag:6];
#else
            UILabel *stepLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - 40)/2, 30, 40)] autorelease];
            [stepLabel setTag: 7];
            [stepLabel setFont:[UIFont boldSystemFontOfSize:16]];
            [stepLabel setAdjustsFontSizeToFitWidth:YES];
            //[stepLabel setTextColor:[UIColor grayColor]];
            [stepLabel setBackgroundColor:[UIColor clearColor]];
            [stepLabel setTextAlignment:UITextAlignmentCenter];
            UILabel *directionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30, 5, DIRECTIONS_LABELS_WIDTH, 15)] autorelease];
            [directionLabel setBackgroundColor:[UIColor clearColor]];
            [directionLabel setFont:[UIFont systemFontOfSize:11]];
            [directionLabel setTag:5];
            [directionLabel setNumberOfLines:1];
            //[directionLabel setAdjustsFontSizeToFitWidth:YES];
            UILabel *distanceLabel = [[[UILabel alloc] initWithFrame:CGRectMake(30, 20, DIRECTIONS_LABELS_WIDTH, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 30)] autorelease];
            [distanceLabel setBackgroundColor:[UIColor clearColor]];
            [distanceLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [distanceLabel setTextAlignment:UITextAlignmentLeft];
            [distanceLabel setNumberOfLines:10];
            [distanceLabel setTag:6];
            [[cell contentView] addSubview:stepLabel];
            [directionLabel setHighlightedTextColor:[UIColor whiteColor]];
            [distanceLabel setHighlightedTextColor:[UIColor whiteColor]];
            [stepLabel setHighlightedTextColor:[UIColor whiteColor]];
#endif       
            
            [[cell contentView] addSubview:directionLabel];
            [[cell contentView] addSubview:distanceLabel];
            
        }
        [cell setBackgroundView:bgView];
        [cell setSelectedBackgroundView:selBgView];
    }
    switch (self.type) {
        case TableTypeStoresCatalog:
        {
            StoreType storeType = [[self.dataSource objectAtIndex:indexPath.row] intValue];
            [cell.imageView setImage:[StoreAnnotation getImageFromType:storeType]];
            [cell.textLabel setText:[StoreAnnotation getStoreNameFromType:storeType]];
            if ([self isIndexEnabled:storeType])
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            else
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
            break;
        case TableTypeConfiguration:
        case TableTypeNearMe:    
        {
            if ([self.dataSource count] == 0) {
                cell.textLabel.text = @"No hay tiendas dentro del rango.";
                cell.imageView.image = nil;
                cell.detailTextLabel.text = nil;
                UILabel *distance = (UILabel*)[cell.contentView viewWithTag:5];
                distance.text = nil;
                cell.accessoryView.hidden = YES;
                return cell;
            }
            StoreLocation *location = [self.dataSource objectAtIndex:indexPath.row];
            StoreType storetype = [StoreAnnotation getTypeFromLocationType: location.type];
            cell.imageView.image = [UIImage imageNamed:[StoreAnnotation getImageNameFromType:storetype]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",[StoreAnnotation getStoreNameFromType:storetype], location.storeName];
//            [cell.detailTextLabel setNumberOfLines:2];
//            cell.detailTextLabel.text = location.storeAddress;
            cell.accessoryView.hidden = NO;
//            UILabel *distance = (UILabel*)[cell.contentView viewWithTag:5];
            if (location.distanceInMeters > 500) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f km",(location.distanceInMeters/1000)];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d m",(int)location.distanceInMeters];
            }
        }
            break;
//        case TableTypeConfiguration:
//        {
//            NSInteger distance = [[self.dataSource objectAtIndex:indexPath.row] intValue];
//            cell.textLabel.text = [NSString stringWithFormat:@"%d km",distance/1000];
//            if ([self isIndexEnabled: distance]) {
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            }
//        }
//            break;
        case TableTypeDirections:
        {
#if DIRECTIONS_FORMAT == 0
            NSDictionary *dictionary = [self.dataSource objectAtIndex:indexPath.row];
            UILabel *directionLabel = (UILabel*)[cell.contentView viewWithTag:5];
            UILabel *distance = (UILabel*)[cell.contentView viewWithTag:6];
            directionLabel.text = [dictionary objectForKey:@"html_instructions"];
            distance.text = [dictionary objectForKey:@"distance"];
            if ([[dictionary objectForKey:@"selected"] boolValue])
                [cell setBackgroundView:[[UIImageView alloc] initWithImage:((UIImageView*)cell.selectedBackgroundView).image]];
#else
            NSDictionary *dictionary = [self.dataSource objectAtIndex:indexPath.row];
            UILabel *directionLabel = (UILabel*)[cell.contentView viewWithTag:5];
            UILabel *distance = (UILabel*)[cell.contentView viewWithTag:6];
            NSNumber *distanceNbr = [[dictionary objectForKey:@"distance"] objectForKey:@"value"];
            NSString *strDistance = nil;
            if ([distanceNbr intValue] > 500) {
                strDistance = [NSString stringWithFormat:@"%.1f km", [distanceNbr floatValue]/1000];
            } else {
                strDistance = [NSString stringWithFormat:@"%d m", [distanceNbr intValue]];
            }
            UILabel *stepLabel = (UILabel*)[cell.contentView viewWithTag:7];
            NSString *directions = [dictionary objectForKey:@"html_instructions"];
            NSString *title = [NSString stringWithFormat:@"Avanza %@ y luego", strDistance];
            directionLabel.text = title;
            distance.text = directions;
            distance.frame = CGRectMake(30, 20, DIRECTIONS_LABELS_WIDTH, [self tableView:tableView heightForRowAtIndexPath:indexPath] - 25);
            if ([[dictionary objectForKey:@"selected"] boolValue]) {
                [cell setBackgroundView:
                 [[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"barraSuperior_inferior.png"]] autorelease]];
                [directionLabel setTextColor:[UIColor whiteColor]];
                [distance setTextColor:[UIColor whiteColor]];
                [stepLabel setTextColor:[UIColor whiteColor]];
            }
            else {
                [cell setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barraNegocio@2x.png"]] autorelease]];
                [directionLabel setTextColor:[UIColor blackColor]];
                [distance setTextColor:[UIColor blackColor]];
                [stepLabel setTextColor:[UIColor blackColor]];
            }
            NSString *stepStr = [NSString stringWithFormat:@"%d", indexPath.row + 1];
            [stepLabel setText:stepStr];
#endif
        }
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {              // Default is 1 if not implemented
    return 1;
}

#pragma mark - 
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.type) {
        case TableTypeStoresCatalog:
        {
            return 50;
        }
            break;
        case TableTypeConfiguration:
        case TableTypeNearMe:
        {
            return 90;
        }
            break;
        case TableTypeDirections:
        {
#if DIRECTIONS_FORMAT == 0
            return 60;
#else
            NSDictionary *dictionary = [self.dataSource objectAtIndex:indexPath.row];
            NSString *string = [dictionary objectForKey:@"html_instructions"];
            return [self heightForDirectionsCell:string] + 20;
#endif
        }
            break;
    }
    return 0;
}

- (CGFloat)heightForDirectionsCell:(NSString *)text {
    CGSize Size = CGSizeMake(DIRECTIONS_LABELS_WIDTH, 300);
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    CGFloat height = 15 + [text sizeWithFont:font constrainedToSize:Size lineBreakMode:UILineBreakModeWordWrap].height;
    //return MAX(height, MinHeight);
    return height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fondo_tituloTiendas_indicaciones.png"]];
    //[imageView setBackgroundColor:[UIColor colorWithRGBValue:0xffffff]];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [imageView setBackgroundColor:[UIColor colorWithRGBValue:0x6cabdd]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont systemFontOfSize:18.0]];
    [title setTextAlignment:UITextAlignmentCenter];
    [imageView addSubview:title];
    if (self.type == TableTypeStoresCatalog) {
        [title setText:@"Negocios"];
    } else if (self.type == TableTypeNearMe) {
        [title setText:@"Tiendas más cercanas"];
    } else if (self.type == TableTypeDirections) {
        [title setText:@"Cómo llegar:"];
    } else if (self.type == TableTypeConfiguration) {
        [title setText:@"Rango de distancia"];
    }
    return imageView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fondo_pieTiendas_indicaciones.png"]];
    [imageView setBackgroundColor:[UIColor colorWithRGBValue:0x6cabdd]];
    return imageView;
}

/*- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *) indexPath{
    UITableViewCellAccessoryType accType = UITableViewCellAccessoryNone;
    if (self.type == TableTypeStoresCatalog) {
        if ([self isIndexEnabled:indexPath.row])
            accType = UITableViewCellAccessoryCheckmark;
    }
    return accType;
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (self.type){
        
        case TableTypeStoresCatalog:
        {
            NSInteger currentValue = [self.enabledFilters indexLessThanOrEqualToIndex:10000];
            NSInteger valueToset = [[self.dataSource objectAtIndex:indexPath.row] intValue];
            
            if (currentValue != valueToset){
                NSInteger index = 0;
                for (NSNumber *number in self.dataSource) {
                    if ([number intValue] == currentValue)
                    {
                        index = [self.dataSource indexOfObject:number];
                        break;
                    }
                }
                UITableViewCell *aCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
                aCell.accessoryType = UITableViewCellAccessoryNone;
                [self toggleIndex:currentValue];
                [self toggleIndex:valueToset];
                if ([self isIndexEnabled:valueToset])
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                else
                    cell.accessoryType = UITableViewCellAccessoryNone;
                [[self delegate] storeLocationConfiguration:self optionSelectedAtIndex:indexPath.row];
            }
        }
            break;
        case TableTypeDirections:
            [[self delegate] storeLocationConfiguration:self optionSelectedAtIndex:indexPath.row];
            [self dismiss];
            break;
        case TableTypeConfiguration:
        case TableTypeNearMe:
        {
            if ([self.dataSource count] != 0)
                [[self delegate] storeLocationConfiguration:self optionSelectedAtIndex:indexPath.row];
        }
            break;
//        case TableTypeStoresCatalog:
//        {
//            StoreType storeType = [[self.dataSource objectAtIndex:indexPath.row] intValue];
//            [self toggleIndex:storeType];
//            if ([self isIndexEnabled:storeType])
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            else
//                cell.accessoryType = UITableViewCellAccessoryNone;
//            [[self delegate] storeLocationConfiguration:self optionSelectedAtIndex:indexPath.row];
//        }
            break;
    }
    [cell setSelected:NO animated:YES];
}


- (BOOL)isIndexEnabled:(NSInteger)index {
    return [[self enabledFilters] containsIndex:index];
}

- (void)toggleIndex:(NSInteger)index {
    if ([[self enabledFilters]containsIndex:index]) {
        [[self enabledFilters] removeIndex:index];
    } else {
        [[self enabledFilters] addIndex:index];
    }
}

- (IBAction)closeButtonPressed {
    [self dismiss];
}

#pragma mark - Slider Events

- (IBAction)sliderChanged:(id)sender
{
    UISlider *slider = sender;
    int sliderValue;
    sliderValue = lroundf(slider.value);
    [slider setValue:sliderValue animated:YES];
    
    {
        if (slider.tag == 1) {  //Distancia
            self.distanceLabel.text = [NSString stringWithFormat:@"Rango de distancia: %d km", sliderValue];
        } else {
            self.storesLabel.text = [NSString stringWithFormat:@"Número de tiendas en mapa: %d", sliderValue];
        }
    }
}

- (IBAction)sliderTouchUp:(id)sender {
    UISlider *slider = sender;
    if (slider.tag == 1) {  //Distancia
        if ([delegate respondsToSelector:@selector(configViewController:didChangeDistanceRange:)]) {
            [delegate configViewController:self didChangeDistanceRange:slider.value];
        }
    } else {
        if ([delegate respondsToSelector:@selector(configViewController:didChangeMaxNearStores:)]) {
            [delegate configViewController:self didChangeMaxNearStores:slider.value];
        }
    }
}

@end
