//
//  TestViewController.h
//  image
//
//  Created by  on 12-7-19.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController: UIViewController<UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    //下拉菜单
    UIActionSheet *myActionSheet;
}

- (void)viewDidLoad;

- (void)openMenu;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)takePhoto;

- (void)LocalPhoto;

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;

- (UIImage *)scaleAndRotateImage:(UIImage *)image andMax:(NSInteger) size;

- (void)viewDidAppear:(BOOL)animated;

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

- (void)viewDidUnload;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
