//
//  Student+CoreDataProperties.m
//  CoreDataDemo
//
//  Created by xt on 2018/12/4.
//  Copyright © 2018 TJ. All rights reserved.
//
//

#import "Student+CoreDataProperties.h"

@implementation Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Student"];
}

@dynamic name;
@dynamic age;
@dynamic number;
@dynamic sex;
@dynamic height;

@end
