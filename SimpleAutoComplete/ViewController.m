//
//  ViewController.m
//  SimpleAutoComplete
//
//  Created by Kirit Vaghela on 17/04/15.
//  Copyright (c) 2015 Kirit Vaghela. All rights reserved.
//

#import "ViewController.h"
#import "DataModels.h"
#import "AFNetworking.h"

#define GoogleDirectionAPI @"AIzaSyCmvC_H5S08MvkO-ixoQTpJQGXdu5qyVWg"

#define kGoogleAutoCompleteAPI @"https://maps.googleapis.com/maps/api/place/autocomplete/json?key=%@&input=%@"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    NSMutableArray *items;
}

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (![textField.text isEqualToString:@""]) {
        [self getAutoCompletePlaces:textField.text];
    }
    
    return YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = items[indexPath.row];
    
    return cell;
}

-(void)getAutoCompletePlaces:(NSString *)searchKey{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // set request timeout
    manager.requestSerializer.timeoutInterval = 5;
    
    NSString *url = [[NSString stringWithFormat:kGoogleAutoCompleteAPI,GoogleDirectionAPI,searchKey] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSLog(@"API : %@",url);
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        
        
        NSDictionary *JSON = responseObject;
        
        items = [NSMutableArray array];
        
        // success
        AutomCompletePlaces *places = [AutomCompletePlaces modelObjectWithDictionary:JSON];
        
        for (Predictions *pred in places.predictions) {
            
            [items addObject:pred.predictionsDescription];

        }
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.searchField.text = items[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
