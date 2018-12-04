//
//  ViewController.m
//  CoreDataDemo
//
//  Created by xt on 2018/12/4.
//  Copyright © 2018 TJ. All rights reserved.
//

#import "ViewController.h"
#import "Student+CoreDataClass.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSManagedObjectContext *context; //管理对象，上下文，持久性存储模型对象，处理数据与应用的交互

@property (nonatomic, strong) Student *selectStudent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self createSqlite];
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.rowHeight = 100;
    [self.view addSubview:self.tableview];
    
    self.tableview.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.tableview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                [NSLayoutConstraint constraintWithItem:self.tableview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                [NSLayoutConstraint constraintWithItem:self.tableview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                                [NSLayoutConstraint constraintWithItem:self.tableview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]
                                ]];
    
    [self reloadData];
}

- (void)reloadData
{
    NSFetchRequest *requst = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    NSArray *resArray = [self.context executeFetchRequest:requst error:nil];
    self.dataSource = [NSMutableArray arrayWithArray:resArray];
    NSLog(@"%@",self.dataSource);
    
    [self.tableview reloadData];
}

- (void)createSqlite
{
    //1、创建模型对象
    //获取模型路径
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    //根据模型文件创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    //2、创建持久化存储助理：数据库
    //利用模型对象创建助理对象
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //数据库的名称和路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"coreData.sqlite"];
    NSLog(@"数据库 path = %@",sqlPath);
    
    NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
    //设置数据库相关信息 添加一个持久化存储库并设置存储类型和路径
    //NSSQLiteStoreType：SQLite作为存储库
    NSError *error = nil;
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
    if (error) {
        NSLog(@"添加数据库失败：%@",error);
    } else {
        NSLog(@"添加数据库成功");
    }
     //3、创建上下文 保存信息 操作数据库
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //关联持久化助理
    self.context.persistentStoreCoordinator = store;
}

- (void)insertData
{
    //1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.context];
    //2.根据表Student中的键值，给NSManagedObject对象赋值
    student.name = [NSString stringWithFormat:@"Mr-%2d",arc4random()%100];
    student.age = arc4random()%22;
    student.sex = arc4random()%2 == 0 ? @"美女" : @"帅哥" ;
    student.height = arc4random()%180;
    student.number = arc4random()%100;
    
    //3.保存插入的数据
    NSError *error = nil;
    if ([self.context save:&error]) {
        NSLog(@"数据插入到数据库成功");
        [self reloadData];
    }else {
        NSLog(@"数据插入到数据库失败,%@",error);
    }
}

- (void)delData
{
    if (self.selectStudent) {
        
//        [self.context deleteObject:self.selectStudent];
        
        //创建请求
        NSFetchRequest *delRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        //条件
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"name == %@",self.selectStudent.name];
        delRequest.predicate = pre;
        //获取符合条件的对象数组
        NSArray *deleArray = [self.context executeFetchRequest:delRequest error:nil];
        //b遍历删除
        for (Student *stu in deleArray) {
            [self.context deleteObject:stu];
        }
        
        NSError *error = nil;
        if ([self.context save:&error]) {
            NSLog(@"删除成功");
            [self reloadData];
            self.selectStudent = nil;
        }else {
            NSLog(@"删除失败:%@",error);
        }
        
    }else {
        
    }
}

- (void)editData
{
    if (self.selectStudent) {
//        self.selectStudent.name = [NSString stringWithFormat:@"修改:%d",arc4random()%100];
        
        //创建请求
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
        //条件
        request.predicate = [NSPredicate predicateWithFormat:@"name == %@",self.selectStudent.name];
        //按条件搜索结果
        NSArray *resArray = [self.context executeFetchRequest:request error:nil];

        //遍历修改
        for (Student *stu in resArray) {
            stu.name = [NSString stringWithFormat:@"修改:%d",arc4random()%100];
        }
        
        NSError *error = nil;
        if ([self.context save:&error]) {
            NSLog(@"修改成功");
            [self reloadData];
            self.selectStudent = nil;
        }else {
            NSLog(@"修改失败:%@",error);
        }
    }else {
        
    }
}

- (void)searchData
{
    /******
     谓词的条件指令
     1.比较运算符 > 、< 、== 、>= 、<= 、!=
     例：@"number >= 99"
     
     2.范围运算符：IN 、BETWEEN
     例：@"number BETWEEN {1,5}"
     @"address IN {'shanghai','nanjing'}"
     
     3.字符串本身:SELF
     例：@"SELF == 'APPLE'"
     
     4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
     例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
     @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
     @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
     
     5.通配符：LIKE
     例：@"name LIKE[cd] '*er*'"   *代表通配符,Like也接受[cd].
     @"name LIKE[cd] '???er*'"
     
     *注*: 星号 "*" : 代表0个或多个字符
     问号 "?" : 代表一个字符
     
     6.正则表达式：MATCHES
     例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
     @"name MATCHES %@",regex
     
     注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
     
     7. 合计操作
     ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
     ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
     NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
     IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
     
     提示:
     1. 谓词中的匹配指令关键字通常使用大写字母
     2. 谓词中可以使用格式字符串
     3. 如果通过对象的key
     path指定匹配条件，需要使用%K
     
     ************/
    
    //创建请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //条件
    request.predicate = [NSPredicate predicateWithFormat:@"sex = %@",self.selectStudent.sex];
    //查询结果
    NSArray *resArray = [self.context executeFetchRequest:request error:nil];
    
    self.dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableview reloadData];
    
    NSLog(@"查询结果：%@",resArray);
}

- (void)sortData
{
    //创建请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    //实例化排序对象
    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
//    NSSortDescriptor *numberSort = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    request.sortDescriptors = @[ageSort];
    
    //开始排序
    NSError *error = nil;
    NSArray *resArray = [self.context executeFetchRequest:request error:&error];
    
    self.dataSource = [NSMutableArray arrayWithArray:resArray];
    [self.tableview reloadData];
    
    if (error == nil) {
        NSLog(@"排序成功");
    }else {
        NSLog(@"排序失败:%@",error);
    }
}






- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    Student *student = self.dataSource[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",student.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"age = %d,sex = %@,height = %d,number = %d",student.age,student.sex,student.height,student.number];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectStudent = self.dataSource[indexPath.row];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor greenColor];
    
    float num = 5.0;
    
    //增加
    UIButton *insertBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    insertBtn.frame = CGRectMake(self.view.bounds.size.width/num * 0, 0, self.view.bounds.size.width/num, 50);
    [insertBtn setTitle:@"add" forState:UIControlStateNormal];
    [insertBtn addTarget:self action:@selector(insertData) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:insertBtn];
    
    //删除
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    delBtn.frame = CGRectMake(self.view.bounds.size.width/num * 1, 0, self.view.bounds.size.width/num, 50);
    [delBtn setTitle:@"del" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delData) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:delBtn];
    
    //编辑
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    editBtn.frame = CGRectMake(self.view.bounds.size.width/num * 2, 0, self.view.bounds.size.width/num, 50);
    [editBtn setTitle:@"edit" forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(editData) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:editBtn];
    
    //查询
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    searchBtn.frame = CGRectMake(self.view.bounds.size.width/num * 3, 0, self.view.bounds.size.width/num, 50);
    [searchBtn setTitle:@"search" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchData) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:searchBtn];
    
    //排序
    UIButton *sortBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    sortBtn.frame = CGRectMake(self.view.bounds.size.width/num * 4, 0, self.view.bounds.size.width/num, 50);
    [sortBtn setTitle:@"sort" forState:UIControlStateNormal];
    [sortBtn addTarget:self action:@selector(sortData) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:sortBtn];
    
    return view;
}

@end
