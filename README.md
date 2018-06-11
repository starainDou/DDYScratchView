# DDYScratchView

# 刮刮乐 刮奖效果

* 建议使用本地图片作为涂层蒙版
* demo只做演示，可自行调整
* demo默认采用长宽各20等分取中部矩形上点作为有效点位进行简单判断，您可以自行根据自己需要去更改，当然最好用自己的算法判断是否算刮完成

![DDYScratchView.png](https://github.com/starainDou/DDYScratchView/blob/master/DDYScratchView.png)


# 使用

```
    __weak __typeof (self)weakSelf = self;
    [self.showButton setHidden:YES];
    DDYScratchView *frontImageView = [[DDYScratchView alloc] initWithFrame:self.contentLabel.frame];
    frontImageView.image = [UIImage imageNamed:@"Scratch"];
    frontImageView.scratchCompleteBlock = ^{
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        strongSelf.showButton.hidden = NO;
    };
    [self.view addSubview:frontImageView];
```    
