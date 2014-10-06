//
//  ImageTestViewController.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/2/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "ImageTestViewController.h"

@interface ImageTestViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.imageView.image = _testImage;
    self.scrollView.contentSize = _testImage.size;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 50;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
