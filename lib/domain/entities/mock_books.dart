import 'package:audiobooks/domain/entities/book_entity.dart';
final List<BookEntity> mockBooks = [
  const BookEntity(
    id: 1,
    title: 'Nhà Giả Kim',
    author: 'Paulo Coelho',
    description: 'Một cuốn sách hay về hành trình theo đuổi ước mơ.',
    // Dùng ảnh placeholder từ một dịch vụ online
    coverImageUrl: 'https://picsum.photos/seed/1/200/300', 
    categoryId: 1,
  ),
  const BookEntity(
    id: 2,
    title: 'Đắc Nhân Tâm',
    author: 'Dale Carnegie',
    description: 'Nghệ thuật giao tiếp và ứng xử.',
    coverImageUrl: 'https://picsum.photos/seed/2/200/300',
    categoryId: 2,
  ),
  const BookEntity(
    id: 3,
    title: 'Lược Sử Loài Người',
    author: 'Yuval Noah Harari',
    description: 'Hành trình tiến hóa của loài người.',
    coverImageUrl: 'https://picsum.photos/seed/3/200/300',
    categoryId: 3,
  ),
  const BookEntity(
    id: 4,
    title: 'Để Gió Cuốn Đi',
    author: 'Margaret Mitchell',
    description: 'Một tác phẩm kinh điển của văn học Mỹ.',
    coverImageUrl: 'https://picsum.photos/seed/4/200/300',
    categoryId: 1,
  ),
];