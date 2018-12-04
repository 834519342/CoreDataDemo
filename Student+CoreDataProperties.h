//
//  Student+CoreDataProperties.h
//  CoreDataDemo
//
//  Created by xt on 2018/12/4.
//  Copyright © 2018 TJ. All rights reserved.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t age;
@property (nonatomic) int16_t number;
@property (nullable, nonatomic, copy) NSString *sex;
@property (nonatomic) int16_t height;

@end

NS_ASSUME_NONNULL_END
