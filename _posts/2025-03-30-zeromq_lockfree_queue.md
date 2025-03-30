---
title: zeromq 中的无锁队列
date: 2025-03-30 21:40:00 +0800
tags: [lockfree, zeromq]
categories: [low latency]
author: latomu
---

# zeromq中的无锁队列

zeromq中有一个很有意思的SPSC无锁队列的实现, 这里记录一下。

主要的实现由两个头文件组成, 分别是yqueue.hpp和ypipe.hpp。 其中ypipe.hpp是上层的无锁队列的实现, 而yqueue.hpp为ypipe.hpp提供了底层的支持。

## yqueue的实现

yqueue底层并没有采用ringbuffer的实现方式， 而是按需分配内存, 当当前缓存区满时(读者赶不上写者)，yqueue会分配一块新的内存块(chunk)用于写入。 相反地，当一个内存块中数据被读者读取完时， yqueue会回收这个块，这里的回收并不会直接将内存归还给操作系统， yqueue会将其缓存起来， 如果写者又开始写入数据， 这个内存块就可以立刻被复用，减少了一次内存分配的时间。不过，为了减少内存占用， 如果yqueue当前已经有一个缓存起来的内存块了，它会立刻把新的空闲内存块给释放掉。

## ypipe的实现

