//
//  TableViewController.m
//  HomeSensor
//
//  Created by Michael Teeuw on 25-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "RecentEventsTableViewController.h"
#import "Api.h"

@interface RecentEventsTableViewController ()

@property (strong, nonatomic) NSArray *events;

@end

@implementation RecentEventsTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = @"Home Sensor";
    
    [self getEvents];
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(getEvents) forControlEvents:UIControlEventValueChanged];

    self.refreshControl = refresh;
    
}


- (void)getEvents
{
    NSLog(@"Get Events");
    
    
    [Api performRequestWithUri:@"event_history" params:nil completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSArray * events = (NSArray *)response;
            NSArray * reversedArray = [[events reverseObjectEnumerator] allObjects];
            
            self.events = reversedArray;
            
            NSLog(@"%@",self.events);
            
            [self.tableView reloadData];
        }
    }];
    
    [self.refreshControl endRefreshing];
}










#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.events count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentEventCell" forIndexPath:indexPath];
    
    NSDictionary *event = self.events[indexPath.row];
    
    NSString *description = [event valueForKeyPath:@"event.description"];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:[[event valueForKey:@"timestamp"] intValue]];
    
    cell.textLabel.text= description;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", timestamp];
    
    return cell;
}


@end
