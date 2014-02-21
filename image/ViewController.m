//
//  TestViewController.m
//  image
//
//  Created by  on 12-7-19.
//  Copyright (c) 2012年 renren. All rights reserved.

#import "ViewController.h"
#import "ImageHelper.h"
#import "ImageProcessor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    //图片按钮。点击后呼出菜单：打开摄像机 查找本地相册 取消
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle]
                                                              pathForResource:@"camera" ofType:@"png"]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(140, 50, image.size.width, image.size.height);
    
    [button setImage:image forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    
    //把按钮加到视图
    [self.view addSubview:button];
}

-(void)openMenu
{
    //呼出下方菜单按钮项
    myActionSheet = [[UIActionSheet alloc]
                 initWithTitle:nil  
                 delegate:self
                 cancelButtonTitle:@"取消"   
                 destructiveButtonTitle:nil
                 otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];  
    
    [myActionSheet showInView:self.view];  
    [myActionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == myActionSheet.cancelButtonIndex) 
    { 
        NSLog(@"取消");
    }
    
    switch (buttonIndex) 
    { 
        case 0:  //打开照相机拍照
            [self takePhoto];
            break; 
      
        case 1:  //打开本地相册
            [self LocalPhoto];
            break; 
    } 
}

//拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self.navigationController presentModalViewController:picker animated:YES];
        [picker release];

    } else
    {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        //把图片旋转正，并把较大边缩到480
        image = [self scaleAndRotateImage:image andMax:480];
 
        //关闭相册界面
        [picker dismissModalViewControllerAnimated:YES];

       
        ///////////////////////////////////////////////////////
        //   1.   用C语言处理图像
        ///////////////////////////////////////////////////////
        
        //创建一个选择后图片的小图标放在下方
        UIImageView *srcImage = [[[UIImageView alloc] initWithFrame:
                                   CGRectMake(50, 120, 80, 120)] autorelease];
        srcImage.image = image;
        [self.view addSubview:srcImage];
        
        int width = image.size.width;
        int height = image.size.height;
        
        // Create a bitmap
        //把图片数据从UIImage转换成4通道的unsigned char
        unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];

        //image processing
        if(1 != reverseImage(bitmap, width, height, 4)) {
            return;
        }
        
        // Create a UIImage using the bitmap
        UIImage *imageCopy = [ImageHelper convertBitmapRGBA8ToUIImage:bitmap
                                                            withWidth:width  withHeight:height];
        // Cleanup
        free(bitmap);

        
        //创建一个小图标放在右边，存结果图片
        UIImageView *dstImage = [[[UIImageView alloc] initWithFrame:
                                    CGRectMake(200, 120, 80, 120)] autorelease];
        dstImage.image = imageCopy;
        [self.view addSubview:dstImage];
        
        
        ///////////////////////////////////////////////////////
        //   2.  用iOS API处理图像
        ///////////////////////////////////////////////////////
        //保存图片
        NSString *dPath=[NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),@"image"];
        NSData *imgData = UIImageJPEGRepresentation(image,0);
        [imgData writeToFile:dPath atomically:YES];
        
        //读取本地图片
        NSString *aPath = [NSString stringWithFormat:@"%@/Documents/%@.jpg",NSHomeDirectory(),@"image"];
        UIImage *imgFromUrl = [[UIImage alloc]initWithContentsOfFile:aPath];
       
        UIImageView* imageView = [[[UIImageView alloc]initWithFrame:
                                    CGRectMake(50, 300, 80, 120)] autorelease];
        imageView.image = imgFromUrl;
        [self.view addSubview:imageView];
        
        //ios image processing
        UIImageView* imageView2 = [[[UIImageView alloc]initWithFrame:
                                   CGRectMake(200, 300, 80, 120)] autorelease];
        imageView2.image = imgFromUrl;
        imageView2.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.view addSubview:imageView2];
    }
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image andMax:(NSInteger) size
{
    if (!image) {
        return nil;
    }
    
    //	static int kMaxResolution = size;
	NSInteger kMaxResolution = size;
	
	CGImageRef imgRef = image.CGImage;
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		} else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
		case UIImageOrientationUp:
			transform = CGAffineTransformIdentity;
			break;
		case UIImageOrientationUpMirrored:
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
		case UIImageOrientationDown:
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
		case UIImageOrientationLeftMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationLeft:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationRightMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		case UIImageOrientationRight:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}
	
    bounds.size.width = floor(bounds.size.width);
    bounds.size.height = floor(bounds.size.height);
    
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}

- (void)viewDidAppear:(BOOL)animated
{
    //隐藏状态bar
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end