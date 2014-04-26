//
//  RegisteredEventsTableViewController.m
//  HomeSensor
//
//  Created by Michael Teeuw on 26-04-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

#import "RegisteredEventsTableViewController.h"
#import "Api.h"
#import "PushNotifier.h"

@interface RegisteredEventsTableViewController ()

@property (strong, nonatomic) NSArray *events;

@end

@implementation RegisteredEventsTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Config";
    
    [self getEvents];
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(getEvents) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
}


- (void)getEvents
{
    NSLog(@"Get Events");
    
    NSString * tokenAsString = [[PushNotifier sharedInstance] deviceTokenAsString];
    
    NSString *apiRequest = [NSString stringWithFormat:@"registered_events?deviceToken=%@", tokenAsString];
    
    [Api performRequestWithUri:apiRequest params:nil completionHandler:^(NSDictionary *response, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error);
        } else {
            NSArray * events = (NSArray *)response;

            
            self.events = events;
            
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"registeredEventCell" forIndexPath:indexPath];
    
    NSDictionary *event = self.events[indexPath.row];
    
    NSString *description = [event valueForKeyPath:@"description"];
    
    cell.textLabel.text= description;
    
    if ([[event valueForKeyPath:@"subscribed"] boolValue]) {
        if ([[event valueForKeyPath:@"repeat"] boolValue]) {
            cell.detailTextLabel.text = @"Continuously";
        } else {
            cell.detailTextLabel.text = @"Once";
        }
    } else {
        cell.detailTextLabel.text = @"";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *event = self.events[indexPath.row];
    NSString *eventIdentifier = [event valueForKeyPath:@"identifier"];
    NSString * tokenAsString = [[PushNotifier sharedInstance] deviceTokenAsString];
    NSString *apiRequest;
    
    if ([[event valueForKeyPath:@"subscribed"] boolValue]) {
        if ([[event valueForKeyPath:@"repeat"] boolValue]) {
            // is continuous, should become none.
            apiRequest = [NSString stringWithFormat:@"unsubscribe?deviceToken=%@&event=%@", tokenAsString, eventIdentifier];
        } else {
            // is once, should become continuous.
            apiRequest = [NSString stringWithFormat:@"subscribe?deviceToken=%@&event=%@&repeat=true", tokenAsString, eventIdentifier];
        }
    } else {
        // is none, shoud become once.
        apiRequest = [NSString stringWithFormat:@"subscribe?deviceToken=%@&event=%@&repeat=false", tokenAsString, eventIdentifier];
    }
    
    [Api performRequestWithUri:apiRequest params:nil completionHandler:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self getEvents];
        }
    }];
}


@end
