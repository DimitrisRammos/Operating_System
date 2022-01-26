
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8c013103          	ld	sp,-1856(sp) # 800088c0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	0a3050ef          	jal	ra,800058b8 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32

  
  struct run *r;

  r = (struct run*)pa;
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	ebad                	bnez	a5,8000009e <kfree+0x82>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00246797          	auipc	a5,0x246
    80000034:	21078793          	addi	a5,a5,528 # 80246240 <end>
    80000038:	06f56363          	bltu	a0,a5,8000009e <kfree+0x82>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	04f57f63          	bgeu	a0,a5,8000009e <kfree+0x82>

  //οταν καλουμε την kfree 
  //εχουμε για καθε σελιδα εναν counter μειωνουμε αυτο το counter 
  //αν ειναι >=1
  int count;
  acquire(&RefTable.lock);
    80000044:	00009517          	auipc	a0,0x9
    80000048:	00c50513          	addi	a0,a0,12 # 80009050 <RefTable>
    8000004c:	00006097          	auipc	ra,0x6
    80000050:	266080e7          	jalr	614(ra) # 800062b2 <acquire>
  count = RefTable.refCounter[(uint64)r/PGSIZE];
    80000054:	00c4d793          	srli	a5,s1,0xc
    80000058:	00478713          	addi	a4,a5,4
    8000005c:	00271693          	slli	a3,a4,0x2
    80000060:	00009717          	auipc	a4,0x9
    80000064:	ff070713          	addi	a4,a4,-16 # 80009050 <RefTable>
    80000068:	9736                	add	a4,a4,a3
    8000006a:	4718                	lw	a4,8(a4)
  

  if(count < 1)
    8000006c:	04e05163          	blez	a4,800000ae <kfree+0x92>
    panic("error kfree");

  RefTable.refCounter[ (uint64)r/PGSIZE]--;
    80000070:	377d                	addiw	a4,a4,-1
    80000072:	0007091b          	sext.w	s2,a4
    80000076:	00009517          	auipc	a0,0x9
    8000007a:	fda50513          	addi	a0,a0,-38 # 80009050 <RefTable>
    8000007e:	0791                	addi	a5,a5,4
    80000080:	078a                	slli	a5,a5,0x2
    80000082:	97aa                	add	a5,a5,a0
    80000084:	c798                	sw	a4,8(a5)
  count = RefTable.refCounter[ (uint64)r/PGSIZE];

  release(&RefTable.lock);
    80000086:	00006097          	auipc	ra,0x6
    8000008a:	2e0080e7          	jalr	736(ra) # 80006366 <release>

  //Αν μετα την μειωση ειναι θετικος ακομα αριθμος και οχι ισος με το 0
  //τοτε δεν διαγραφουμε την σελιδα καθως ακομη υπαρχουν αλλη ή αλλες διεργγασιες
  //που δειχνουν σε αυτην
  if( count > 0)
    8000008e:	03205863          	blez	s2,800000be <kfree+0xa2>

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}
    80000092:	60e2                	ld	ra,24(sp)
    80000094:	6442                	ld	s0,16(sp)
    80000096:	64a2                	ld	s1,8(sp)
    80000098:	6902                	ld	s2,0(sp)
    8000009a:	6105                	addi	sp,sp,32
    8000009c:	8082                	ret
    panic("kfree");
    8000009e:	00008517          	auipc	a0,0x8
    800000a2:	f7250513          	addi	a0,a0,-142 # 80008010 <etext+0x10>
    800000a6:	00006097          	auipc	ra,0x6
    800000aa:	cc2080e7          	jalr	-830(ra) # 80005d68 <panic>
    panic("error kfree");
    800000ae:	00008517          	auipc	a0,0x8
    800000b2:	f6a50513          	addi	a0,a0,-150 # 80008018 <etext+0x18>
    800000b6:	00006097          	auipc	ra,0x6
    800000ba:	cb2080e7          	jalr	-846(ra) # 80005d68 <panic>
  memset(pa, 1, PGSIZE);
    800000be:	6605                	lui	a2,0x1
    800000c0:	4585                	li	a1,1
    800000c2:	8526                	mv	a0,s1
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	1f0080e7          	jalr	496(ra) # 800002b4 <memset>
  acquire(&kmem.lock);
    800000cc:	00009917          	auipc	s2,0x9
    800000d0:	f6490913          	addi	s2,s2,-156 # 80009030 <kmem>
    800000d4:	854a                	mv	a0,s2
    800000d6:	00006097          	auipc	ra,0x6
    800000da:	1dc080e7          	jalr	476(ra) # 800062b2 <acquire>
  r->next = kmem.freelist;
    800000de:	01893783          	ld	a5,24(s2)
    800000e2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800000e4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800000e8:	854a                	mv	a0,s2
    800000ea:	00006097          	auipc	ra,0x6
    800000ee:	27c080e7          	jalr	636(ra) # 80006366 <release>
    800000f2:	b745                	j	80000092 <kfree+0x76>

00000000800000f4 <freerange>:
{
    800000f4:	7139                	addi	sp,sp,-64
    800000f6:	fc06                	sd	ra,56(sp)
    800000f8:	f822                	sd	s0,48(sp)
    800000fa:	f426                	sd	s1,40(sp)
    800000fc:	f04a                	sd	s2,32(sp)
    800000fe:	ec4e                	sd	s3,24(sp)
    80000100:	e852                	sd	s4,16(sp)
    80000102:	e456                	sd	s5,8(sp)
    80000104:	e05a                	sd	s6,0(sp)
    80000106:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000108:	6785                	lui	a5,0x1
    8000010a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    8000010e:	9526                	add	a0,a0,s1
    80000110:	74fd                	lui	s1,0xfffff
    80000112:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000114:	97a6                	add	a5,a5,s1
    80000116:	02f5eb63          	bltu	a1,a5,8000014c <freerange+0x58>
    8000011a:	892e                	mv	s2,a1
    RefTable.refCounter[ (uint64)p/PGSIZE] = 1;
    8000011c:	00009b17          	auipc	s6,0x9
    80000120:	f34b0b13          	addi	s6,s6,-204 # 80009050 <RefTable>
    80000124:	4a85                	li	s5,1
    80000126:	6a05                	lui	s4,0x1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000128:	6989                	lui	s3,0x2
    RefTable.refCounter[ (uint64)p/PGSIZE] = 1;
    8000012a:	00c4d793          	srli	a5,s1,0xc
    8000012e:	0791                	addi	a5,a5,4
    80000130:	078a                	slli	a5,a5,0x2
    80000132:	97da                	add	a5,a5,s6
    80000134:	0157a423          	sw	s5,8(a5)
    kfree(p);
    80000138:	8526                	mv	a0,s1
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	ee2080e7          	jalr	-286(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000142:	87a6                	mv	a5,s1
    80000144:	94d2                	add	s1,s1,s4
    80000146:	97ce                	add	a5,a5,s3
    80000148:	fef971e3          	bgeu	s2,a5,8000012a <freerange+0x36>
}
    8000014c:	70e2                	ld	ra,56(sp)
    8000014e:	7442                	ld	s0,48(sp)
    80000150:	74a2                	ld	s1,40(sp)
    80000152:	7902                	ld	s2,32(sp)
    80000154:	69e2                	ld	s3,24(sp)
    80000156:	6a42                	ld	s4,16(sp)
    80000158:	6aa2                	ld	s5,8(sp)
    8000015a:	6b02                	ld	s6,0(sp)
    8000015c:	6121                	addi	sp,sp,64
    8000015e:	8082                	ret

0000000080000160 <kinit>:
{
    80000160:	1141                	addi	sp,sp,-16
    80000162:	e406                	sd	ra,8(sp)
    80000164:	e022                	sd	s0,0(sp)
    80000166:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000168:	00008597          	auipc	a1,0x8
    8000016c:	ec058593          	addi	a1,a1,-320 # 80008028 <etext+0x28>
    80000170:	00009517          	auipc	a0,0x9
    80000174:	ec050513          	addi	a0,a0,-320 # 80009030 <kmem>
    80000178:	00006097          	auipc	ra,0x6
    8000017c:	0aa080e7          	jalr	170(ra) # 80006222 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000180:	45c5                	li	a1,17
    80000182:	05ee                	slli	a1,a1,0x1b
    80000184:	00246517          	auipc	a0,0x246
    80000188:	0bc50513          	addi	a0,a0,188 # 80246240 <end>
    8000018c:	00000097          	auipc	ra,0x0
    80000190:	f68080e7          	jalr	-152(ra) # 800000f4 <freerange>
}
    80000194:	60a2                	ld	ra,8(sp)
    80000196:	6402                	ld	s0,0(sp)
    80000198:	0141                	addi	sp,sp,16
    8000019a:	8082                	ret

000000008000019c <RefPlus>:

//Η συναρτηση αυτη αυξανει το counter  της συγκεκριμενης σελιδας pa καθως δειχνει 
//+1 διεργασια σε αυτην
void 
RefPlus( uint64 pa)
{
    8000019c:	1101                	addi	sp,sp,-32
    8000019e:	ec06                	sd	ra,24(sp)
    800001a0:	e822                	sd	s0,16(sp)
    800001a2:	e426                	sd	s1,8(sp)
    800001a4:	1000                	addi	s0,sp,32
    800001a6:	84aa                	mv	s1,a0
  acquire(&RefTable.lock);
    800001a8:	00009517          	auipc	a0,0x9
    800001ac:	ea850513          	addi	a0,a0,-344 # 80009050 <RefTable>
    800001b0:	00006097          	auipc	ra,0x6
    800001b4:	102080e7          	jalr	258(ra) # 800062b2 <acquire>
  
  if( pa > PHYSTOP)
    800001b8:	47c5                	li	a5,17
    800001ba:	07ee                	slli	a5,a5,0x1b
    800001bc:	0497e163          	bltu	a5,s1,800001fe <RefPlus+0x62>
    panic("ERROR refplus");

  if( RefTable.refCounter[ pa/PGSIZE] < 1)
    800001c0:	80b1                	srli	s1,s1,0xc
    800001c2:	00448793          	addi	a5,s1,4 # fffffffffffff004 <end+0xffffffff7fdb8dc4>
    800001c6:	00279713          	slli	a4,a5,0x2
    800001ca:	00009797          	auipc	a5,0x9
    800001ce:	e8678793          	addi	a5,a5,-378 # 80009050 <RefTable>
    800001d2:	97ba                	add	a5,a5,a4
    800001d4:	479c                	lw	a5,8(a5)
    800001d6:	02f05c63          	blez	a5,8000020e <RefPlus+0x72>
    panic("Error refplus");
  RefTable.refCounter[ pa/PGSIZE]++;
    800001da:	00009517          	auipc	a0,0x9
    800001de:	e7650513          	addi	a0,a0,-394 # 80009050 <RefTable>
    800001e2:	0491                	addi	s1,s1,4
    800001e4:	048a                	slli	s1,s1,0x2
    800001e6:	94aa                	add	s1,s1,a0
    800001e8:	2785                	addiw	a5,a5,1
    800001ea:	c49c                	sw	a5,8(s1)

  release(&RefTable.lock);
    800001ec:	00006097          	auipc	ra,0x6
    800001f0:	17a080e7          	jalr	378(ra) # 80006366 <release>
}
    800001f4:	60e2                	ld	ra,24(sp)
    800001f6:	6442                	ld	s0,16(sp)
    800001f8:	64a2                	ld	s1,8(sp)
    800001fa:	6105                	addi	sp,sp,32
    800001fc:	8082                	ret
    panic("ERROR refplus");
    800001fe:	00008517          	auipc	a0,0x8
    80000202:	e3250513          	addi	a0,a0,-462 # 80008030 <etext+0x30>
    80000206:	00006097          	auipc	ra,0x6
    8000020a:	b62080e7          	jalr	-1182(ra) # 80005d68 <panic>
    panic("Error refplus");
    8000020e:	00008517          	auipc	a0,0x8
    80000212:	e3250513          	addi	a0,a0,-462 # 80008040 <etext+0x40>
    80000216:	00006097          	auipc	ra,0x6
    8000021a:	b52080e7          	jalr	-1198(ra) # 80005d68 <panic>

000000008000021e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    8000021e:	1101                	addi	sp,sp,-32
    80000220:	ec06                	sd	ra,24(sp)
    80000222:	e822                	sd	s0,16(sp)
    80000224:	e426                	sd	s1,8(sp)
    80000226:	e04a                	sd	s2,0(sp)
    80000228:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000022a:	00009497          	auipc	s1,0x9
    8000022e:	e0648493          	addi	s1,s1,-506 # 80009030 <kmem>
    80000232:	8526                	mv	a0,s1
    80000234:	00006097          	auipc	ra,0x6
    80000238:	07e080e7          	jalr	126(ra) # 800062b2 <acquire>
  r = kmem.freelist;
    8000023c:	6c84                	ld	s1,24(s1)
  if(r)
    8000023e:	c0b5                	beqz	s1,800002a2 <kalloc+0x84>
  {
    kmem.freelist = r->next;
    80000240:	609c                	ld	a5,0(s1)
    80000242:	00009917          	auipc	s2,0x9
    80000246:	dee90913          	addi	s2,s2,-530 # 80009030 <kmem>
    8000024a:	00f93c23          	sd	a5,24(s2)
    acquire(&RefTable.lock);
    8000024e:	00009517          	auipc	a0,0x9
    80000252:	e0250513          	addi	a0,a0,-510 # 80009050 <RefTable>
    80000256:	00006097          	auipc	ra,0x6
    8000025a:	05c080e7          	jalr	92(ra) # 800062b2 <acquire>
    
    //οταν δημιουργω μια καινουρια σελιδα τοτε 
    //αρχικοποιω τον μετρητη της σε 1
    RefTable.refCounter[ (uint64)r/PGSIZE] = 1;
    8000025e:	00009517          	auipc	a0,0x9
    80000262:	df250513          	addi	a0,a0,-526 # 80009050 <RefTable>
    80000266:	00c4d793          	srli	a5,s1,0xc
    8000026a:	0791                	addi	a5,a5,4
    8000026c:	078a                	slli	a5,a5,0x2
    8000026e:	97aa                	add	a5,a5,a0
    80000270:	4705                	li	a4,1
    80000272:	c798                	sw	a4,8(a5)
    release(&RefTable.lock);
    80000274:	00006097          	auipc	ra,0x6
    80000278:	0f2080e7          	jalr	242(ra) # 80006366 <release>
  }
  release(&kmem.lock);
    8000027c:	854a                	mv	a0,s2
    8000027e:	00006097          	auipc	ra,0x6
    80000282:	0e8080e7          	jalr	232(ra) # 80006366 <release>

 

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000286:	6605                	lui	a2,0x1
    80000288:	4595                	li	a1,5
    8000028a:	8526                	mv	a0,s1
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	028080e7          	jalr	40(ra) # 800002b4 <memset>
  return (void*)r;
}
    80000294:	8526                	mv	a0,s1
    80000296:	60e2                	ld	ra,24(sp)
    80000298:	6442                	ld	s0,16(sp)
    8000029a:	64a2                	ld	s1,8(sp)
    8000029c:	6902                	ld	s2,0(sp)
    8000029e:	6105                	addi	sp,sp,32
    800002a0:	8082                	ret
  release(&kmem.lock);
    800002a2:	00009517          	auipc	a0,0x9
    800002a6:	d8e50513          	addi	a0,a0,-626 # 80009030 <kmem>
    800002aa:	00006097          	auipc	ra,0x6
    800002ae:	0bc080e7          	jalr	188(ra) # 80006366 <release>
  if(r)
    800002b2:	b7cd                	j	80000294 <kalloc+0x76>

00000000800002b4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800002b4:	1141                	addi	sp,sp,-16
    800002b6:	e422                	sd	s0,8(sp)
    800002b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800002ba:	ce09                	beqz	a2,800002d4 <memset+0x20>
    800002bc:	87aa                	mv	a5,a0
    800002be:	fff6071b          	addiw	a4,a2,-1
    800002c2:	1702                	slli	a4,a4,0x20
    800002c4:	9301                	srli	a4,a4,0x20
    800002c6:	0705                	addi	a4,a4,1
    800002c8:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800002ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800002ce:	0785                	addi	a5,a5,1
    800002d0:	fee79de3          	bne	a5,a4,800002ca <memset+0x16>
  }
  return dst;
}
    800002d4:	6422                	ld	s0,8(sp)
    800002d6:	0141                	addi	sp,sp,16
    800002d8:	8082                	ret

00000000800002da <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800002da:	1141                	addi	sp,sp,-16
    800002dc:	e422                	sd	s0,8(sp)
    800002de:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800002e0:	ca05                	beqz	a2,80000310 <memcmp+0x36>
    800002e2:	fff6069b          	addiw	a3,a2,-1
    800002e6:	1682                	slli	a3,a3,0x20
    800002e8:	9281                	srli	a3,a3,0x20
    800002ea:	0685                	addi	a3,a3,1
    800002ec:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800002ee:	00054783          	lbu	a5,0(a0)
    800002f2:	0005c703          	lbu	a4,0(a1)
    800002f6:	00e79863          	bne	a5,a4,80000306 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800002fa:	0505                	addi	a0,a0,1
    800002fc:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800002fe:	fed518e3          	bne	a0,a3,800002ee <memcmp+0x14>
  }

  return 0;
    80000302:	4501                	li	a0,0
    80000304:	a019                	j	8000030a <memcmp+0x30>
      return *s1 - *s2;
    80000306:	40e7853b          	subw	a0,a5,a4
}
    8000030a:	6422                	ld	s0,8(sp)
    8000030c:	0141                	addi	sp,sp,16
    8000030e:	8082                	ret
  return 0;
    80000310:	4501                	li	a0,0
    80000312:	bfe5                	j	8000030a <memcmp+0x30>

0000000080000314 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000314:	1141                	addi	sp,sp,-16
    80000316:	e422                	sd	s0,8(sp)
    80000318:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    8000031a:	ca0d                	beqz	a2,8000034c <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000031c:	00a5f963          	bgeu	a1,a0,8000032e <memmove+0x1a>
    80000320:	02061693          	slli	a3,a2,0x20
    80000324:	9281                	srli	a3,a3,0x20
    80000326:	00d58733          	add	a4,a1,a3
    8000032a:	02e56463          	bltu	a0,a4,80000352 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000032e:	fff6079b          	addiw	a5,a2,-1
    80000332:	1782                	slli	a5,a5,0x20
    80000334:	9381                	srli	a5,a5,0x20
    80000336:	0785                	addi	a5,a5,1
    80000338:	97ae                	add	a5,a5,a1
    8000033a:	872a                	mv	a4,a0
      *d++ = *s++;
    8000033c:	0585                	addi	a1,a1,1
    8000033e:	0705                	addi	a4,a4,1
    80000340:	fff5c683          	lbu	a3,-1(a1)
    80000344:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000348:	fef59ae3          	bne	a1,a5,8000033c <memmove+0x28>

  return dst;
}
    8000034c:	6422                	ld	s0,8(sp)
    8000034e:	0141                	addi	sp,sp,16
    80000350:	8082                	ret
    d += n;
    80000352:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000354:	fff6079b          	addiw	a5,a2,-1
    80000358:	1782                	slli	a5,a5,0x20
    8000035a:	9381                	srli	a5,a5,0x20
    8000035c:	fff7c793          	not	a5,a5
    80000360:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000362:	177d                	addi	a4,a4,-1
    80000364:	16fd                	addi	a3,a3,-1
    80000366:	00074603          	lbu	a2,0(a4)
    8000036a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    8000036e:	fef71ae3          	bne	a4,a5,80000362 <memmove+0x4e>
    80000372:	bfe9                	j	8000034c <memmove+0x38>

0000000080000374 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000374:	1141                	addi	sp,sp,-16
    80000376:	e406                	sd	ra,8(sp)
    80000378:	e022                	sd	s0,0(sp)
    8000037a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000037c:	00000097          	auipc	ra,0x0
    80000380:	f98080e7          	jalr	-104(ra) # 80000314 <memmove>
}
    80000384:	60a2                	ld	ra,8(sp)
    80000386:	6402                	ld	s0,0(sp)
    80000388:	0141                	addi	sp,sp,16
    8000038a:	8082                	ret

000000008000038c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000038c:	1141                	addi	sp,sp,-16
    8000038e:	e422                	sd	s0,8(sp)
    80000390:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000392:	ce11                	beqz	a2,800003ae <strncmp+0x22>
    80000394:	00054783          	lbu	a5,0(a0)
    80000398:	cf89                	beqz	a5,800003b2 <strncmp+0x26>
    8000039a:	0005c703          	lbu	a4,0(a1)
    8000039e:	00f71a63          	bne	a4,a5,800003b2 <strncmp+0x26>
    n--, p++, q++;
    800003a2:	367d                	addiw	a2,a2,-1
    800003a4:	0505                	addi	a0,a0,1
    800003a6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800003a8:	f675                	bnez	a2,80000394 <strncmp+0x8>
  if(n == 0)
    return 0;
    800003aa:	4501                	li	a0,0
    800003ac:	a809                	j	800003be <strncmp+0x32>
    800003ae:	4501                	li	a0,0
    800003b0:	a039                	j	800003be <strncmp+0x32>
  if(n == 0)
    800003b2:	ca09                	beqz	a2,800003c4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800003b4:	00054503          	lbu	a0,0(a0)
    800003b8:	0005c783          	lbu	a5,0(a1)
    800003bc:	9d1d                	subw	a0,a0,a5
}
    800003be:	6422                	ld	s0,8(sp)
    800003c0:	0141                	addi	sp,sp,16
    800003c2:	8082                	ret
    return 0;
    800003c4:	4501                	li	a0,0
    800003c6:	bfe5                	j	800003be <strncmp+0x32>

00000000800003c8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800003c8:	1141                	addi	sp,sp,-16
    800003ca:	e422                	sd	s0,8(sp)
    800003cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800003ce:	872a                	mv	a4,a0
    800003d0:	8832                	mv	a6,a2
    800003d2:	367d                	addiw	a2,a2,-1
    800003d4:	01005963          	blez	a6,800003e6 <strncpy+0x1e>
    800003d8:	0705                	addi	a4,a4,1
    800003da:	0005c783          	lbu	a5,0(a1)
    800003de:	fef70fa3          	sb	a5,-1(a4)
    800003e2:	0585                	addi	a1,a1,1
    800003e4:	f7f5                	bnez	a5,800003d0 <strncpy+0x8>
    ;
  while(n-- > 0)
    800003e6:	00c05d63          	blez	a2,80000400 <strncpy+0x38>
    800003ea:	86ba                	mv	a3,a4
    *s++ = 0;
    800003ec:	0685                	addi	a3,a3,1
    800003ee:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800003f2:	fff6c793          	not	a5,a3
    800003f6:	9fb9                	addw	a5,a5,a4
    800003f8:	010787bb          	addw	a5,a5,a6
    800003fc:	fef048e3          	bgtz	a5,800003ec <strncpy+0x24>
  return os;
}
    80000400:	6422                	ld	s0,8(sp)
    80000402:	0141                	addi	sp,sp,16
    80000404:	8082                	ret

0000000080000406 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000406:	1141                	addi	sp,sp,-16
    80000408:	e422                	sd	s0,8(sp)
    8000040a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    8000040c:	02c05363          	blez	a2,80000432 <safestrcpy+0x2c>
    80000410:	fff6069b          	addiw	a3,a2,-1
    80000414:	1682                	slli	a3,a3,0x20
    80000416:	9281                	srli	a3,a3,0x20
    80000418:	96ae                	add	a3,a3,a1
    8000041a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000041c:	00d58963          	beq	a1,a3,8000042e <safestrcpy+0x28>
    80000420:	0585                	addi	a1,a1,1
    80000422:	0785                	addi	a5,a5,1
    80000424:	fff5c703          	lbu	a4,-1(a1)
    80000428:	fee78fa3          	sb	a4,-1(a5)
    8000042c:	fb65                	bnez	a4,8000041c <safestrcpy+0x16>
    ;
  *s = 0;
    8000042e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000432:	6422                	ld	s0,8(sp)
    80000434:	0141                	addi	sp,sp,16
    80000436:	8082                	ret

0000000080000438 <strlen>:

int
strlen(const char *s)
{
    80000438:	1141                	addi	sp,sp,-16
    8000043a:	e422                	sd	s0,8(sp)
    8000043c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000043e:	00054783          	lbu	a5,0(a0)
    80000442:	cf91                	beqz	a5,8000045e <strlen+0x26>
    80000444:	0505                	addi	a0,a0,1
    80000446:	87aa                	mv	a5,a0
    80000448:	4685                	li	a3,1
    8000044a:	9e89                	subw	a3,a3,a0
    8000044c:	00f6853b          	addw	a0,a3,a5
    80000450:	0785                	addi	a5,a5,1
    80000452:	fff7c703          	lbu	a4,-1(a5)
    80000456:	fb7d                	bnez	a4,8000044c <strlen+0x14>
    ;
  return n;
}
    80000458:	6422                	ld	s0,8(sp)
    8000045a:	0141                	addi	sp,sp,16
    8000045c:	8082                	ret
  for(n = 0; s[n]; n++)
    8000045e:	4501                	li	a0,0
    80000460:	bfe5                	j	80000458 <strlen+0x20>

0000000080000462 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000462:	1141                	addi	sp,sp,-16
    80000464:	e406                	sd	ra,8(sp)
    80000466:	e022                	sd	s0,0(sp)
    80000468:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000046a:	00001097          	auipc	ra,0x1
    8000046e:	b36080e7          	jalr	-1226(ra) # 80000fa0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000472:	00009717          	auipc	a4,0x9
    80000476:	b8e70713          	addi	a4,a4,-1138 # 80009000 <started>
  if(cpuid() == 0){
    8000047a:	c139                	beqz	a0,800004c0 <main+0x5e>
    while(started == 0)
    8000047c:	431c                	lw	a5,0(a4)
    8000047e:	2781                	sext.w	a5,a5
    80000480:	dff5                	beqz	a5,8000047c <main+0x1a>
      ;
    __sync_synchronize();
    80000482:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000486:	00001097          	auipc	ra,0x1
    8000048a:	b1a080e7          	jalr	-1254(ra) # 80000fa0 <cpuid>
    8000048e:	85aa                	mv	a1,a0
    80000490:	00008517          	auipc	a0,0x8
    80000494:	bd850513          	addi	a0,a0,-1064 # 80008068 <etext+0x68>
    80000498:	00006097          	auipc	ra,0x6
    8000049c:	91a080e7          	jalr	-1766(ra) # 80005db2 <printf>
    kvminithart();    // turn on paging
    800004a0:	00000097          	auipc	ra,0x0
    800004a4:	0d8080e7          	jalr	216(ra) # 80000578 <kvminithart>
    trapinithart();   // install kernel trap vector
    800004a8:	00001097          	auipc	ra,0x1
    800004ac:	770080e7          	jalr	1904(ra) # 80001c18 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800004b0:	00005097          	auipc	ra,0x5
    800004b4:	d90080e7          	jalr	-624(ra) # 80005240 <plicinithart>
  }

  scheduler();        
    800004b8:	00001097          	auipc	ra,0x1
    800004bc:	01e080e7          	jalr	30(ra) # 800014d6 <scheduler>
    consoleinit();
    800004c0:	00005097          	auipc	ra,0x5
    800004c4:	7ba080e7          	jalr	1978(ra) # 80005c7a <consoleinit>
    printfinit();
    800004c8:	00006097          	auipc	ra,0x6
    800004cc:	ad0080e7          	jalr	-1328(ra) # 80005f98 <printfinit>
    printf("\n");
    800004d0:	00008517          	auipc	a0,0x8
    800004d4:	ba850513          	addi	a0,a0,-1112 # 80008078 <etext+0x78>
    800004d8:	00006097          	auipc	ra,0x6
    800004dc:	8da080e7          	jalr	-1830(ra) # 80005db2 <printf>
    printf("xv6 kernel is booting\n");
    800004e0:	00008517          	auipc	a0,0x8
    800004e4:	b7050513          	addi	a0,a0,-1168 # 80008050 <etext+0x50>
    800004e8:	00006097          	auipc	ra,0x6
    800004ec:	8ca080e7          	jalr	-1846(ra) # 80005db2 <printf>
    printf("\n");
    800004f0:	00008517          	auipc	a0,0x8
    800004f4:	b8850513          	addi	a0,a0,-1144 # 80008078 <etext+0x78>
    800004f8:	00006097          	auipc	ra,0x6
    800004fc:	8ba080e7          	jalr	-1862(ra) # 80005db2 <printf>
    kinit();         // physical page allocator
    80000500:	00000097          	auipc	ra,0x0
    80000504:	c60080e7          	jalr	-928(ra) # 80000160 <kinit>
    kvminit();       // create kernel page table
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	328080e7          	jalr	808(ra) # 80000830 <kvminit>
    kvminithart();   // turn on paging
    80000510:	00000097          	auipc	ra,0x0
    80000514:	068080e7          	jalr	104(ra) # 80000578 <kvminithart>
    procinit();      // process table
    80000518:	00001097          	auipc	ra,0x1
    8000051c:	9d8080e7          	jalr	-1576(ra) # 80000ef0 <procinit>
    trapinit();      // trap vectors
    80000520:	00001097          	auipc	ra,0x1
    80000524:	6d0080e7          	jalr	1744(ra) # 80001bf0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000528:	00001097          	auipc	ra,0x1
    8000052c:	6f0080e7          	jalr	1776(ra) # 80001c18 <trapinithart>
    plicinit();      // set up interrupt controller
    80000530:	00005097          	auipc	ra,0x5
    80000534:	cfa080e7          	jalr	-774(ra) # 8000522a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000538:	00005097          	auipc	ra,0x5
    8000053c:	d08080e7          	jalr	-760(ra) # 80005240 <plicinithart>
    binit();         // buffer cache
    80000540:	00002097          	auipc	ra,0x2
    80000544:	ee0080e7          	jalr	-288(ra) # 80002420 <binit>
    iinit();         // inode table
    80000548:	00002097          	auipc	ra,0x2
    8000054c:	570080e7          	jalr	1392(ra) # 80002ab8 <iinit>
    fileinit();      // file table
    80000550:	00003097          	auipc	ra,0x3
    80000554:	51a080e7          	jalr	1306(ra) # 80003a6a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000558:	00005097          	auipc	ra,0x5
    8000055c:	e0a080e7          	jalr	-502(ra) # 80005362 <virtio_disk_init>
    userinit();      // first user process
    80000560:	00001097          	auipc	ra,0x1
    80000564:	d44080e7          	jalr	-700(ra) # 800012a4 <userinit>
    __sync_synchronize();
    80000568:	0ff0000f          	fence
    started = 1;
    8000056c:	4785                	li	a5,1
    8000056e:	00009717          	auipc	a4,0x9
    80000572:	a8f72923          	sw	a5,-1390(a4) # 80009000 <started>
    80000576:	b789                	j	800004b8 <main+0x56>

0000000080000578 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000578:	1141                	addi	sp,sp,-16
    8000057a:	e422                	sd	s0,8(sp)
    8000057c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000057e:	00009797          	auipc	a5,0x9
    80000582:	a8a7b783          	ld	a5,-1398(a5) # 80009008 <kernel_pagetable>
    80000586:	83b1                	srli	a5,a5,0xc
    80000588:	577d                	li	a4,-1
    8000058a:	177e                	slli	a4,a4,0x3f
    8000058c:	8fd9                	or	a5,a5,a4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    8000058e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000592:	12000073          	sfence.vma
  sfence_vma();
}
    80000596:	6422                	ld	s0,8(sp)
    80000598:	0141                	addi	sp,sp,16
    8000059a:	8082                	ret

000000008000059c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000059c:	7139                	addi	sp,sp,-64
    8000059e:	fc06                	sd	ra,56(sp)
    800005a0:	f822                	sd	s0,48(sp)
    800005a2:	f426                	sd	s1,40(sp)
    800005a4:	f04a                	sd	s2,32(sp)
    800005a6:	ec4e                	sd	s3,24(sp)
    800005a8:	e852                	sd	s4,16(sp)
    800005aa:	e456                	sd	s5,8(sp)
    800005ac:	e05a                	sd	s6,0(sp)
    800005ae:	0080                	addi	s0,sp,64
    800005b0:	84aa                	mv	s1,a0
    800005b2:	89ae                	mv	s3,a1
    800005b4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800005b6:	57fd                	li	a5,-1
    800005b8:	83e9                	srli	a5,a5,0x1a
    800005ba:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800005bc:	4b31                	li	s6,12
  if(va >= MAXVA)
    800005be:	04b7f263          	bgeu	a5,a1,80000602 <walk+0x66>
    panic("walk");
    800005c2:	00008517          	auipc	a0,0x8
    800005c6:	abe50513          	addi	a0,a0,-1346 # 80008080 <etext+0x80>
    800005ca:	00005097          	auipc	ra,0x5
    800005ce:	79e080e7          	jalr	1950(ra) # 80005d68 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800005d2:	060a8663          	beqz	s5,8000063e <walk+0xa2>
    800005d6:	00000097          	auipc	ra,0x0
    800005da:	c48080e7          	jalr	-952(ra) # 8000021e <kalloc>
    800005de:	84aa                	mv	s1,a0
    800005e0:	c529                	beqz	a0,8000062a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800005e2:	6605                	lui	a2,0x1
    800005e4:	4581                	li	a1,0
    800005e6:	00000097          	auipc	ra,0x0
    800005ea:	cce080e7          	jalr	-818(ra) # 800002b4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800005ee:	00c4d793          	srli	a5,s1,0xc
    800005f2:	07aa                	slli	a5,a5,0xa
    800005f4:	0017e793          	ori	a5,a5,1
    800005f8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800005fc:	3a5d                	addiw	s4,s4,-9
    800005fe:	036a0063          	beq	s4,s6,8000061e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000602:	0149d933          	srl	s2,s3,s4
    80000606:	1ff97913          	andi	s2,s2,511
    8000060a:	090e                	slli	s2,s2,0x3
    8000060c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000060e:	00093483          	ld	s1,0(s2)
    80000612:	0014f793          	andi	a5,s1,1
    80000616:	dfd5                	beqz	a5,800005d2 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000618:	80a9                	srli	s1,s1,0xa
    8000061a:	04b2                	slli	s1,s1,0xc
    8000061c:	b7c5                	j	800005fc <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000061e:	00c9d513          	srli	a0,s3,0xc
    80000622:	1ff57513          	andi	a0,a0,511
    80000626:	050e                	slli	a0,a0,0x3
    80000628:	9526                	add	a0,a0,s1
}
    8000062a:	70e2                	ld	ra,56(sp)
    8000062c:	7442                	ld	s0,48(sp)
    8000062e:	74a2                	ld	s1,40(sp)
    80000630:	7902                	ld	s2,32(sp)
    80000632:	69e2                	ld	s3,24(sp)
    80000634:	6a42                	ld	s4,16(sp)
    80000636:	6aa2                	ld	s5,8(sp)
    80000638:	6b02                	ld	s6,0(sp)
    8000063a:	6121                	addi	sp,sp,64
    8000063c:	8082                	ret
        return 0;
    8000063e:	4501                	li	a0,0
    80000640:	b7ed                	j	8000062a <walk+0x8e>

0000000080000642 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000642:	57fd                	li	a5,-1
    80000644:	83e9                	srli	a5,a5,0x1a
    80000646:	00b7f463          	bgeu	a5,a1,8000064e <walkaddr+0xc>
    return 0;
    8000064a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000064c:	8082                	ret
{
    8000064e:	1141                	addi	sp,sp,-16
    80000650:	e406                	sd	ra,8(sp)
    80000652:	e022                	sd	s0,0(sp)
    80000654:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000656:	4601                	li	a2,0
    80000658:	00000097          	auipc	ra,0x0
    8000065c:	f44080e7          	jalr	-188(ra) # 8000059c <walk>
  if(pte == 0)
    80000660:	c105                	beqz	a0,80000680 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000662:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000664:	0117f693          	andi	a3,a5,17
    80000668:	4745                	li	a4,17
    return 0;
    8000066a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000066c:	00e68663          	beq	a3,a4,80000678 <walkaddr+0x36>
}
    80000670:	60a2                	ld	ra,8(sp)
    80000672:	6402                	ld	s0,0(sp)
    80000674:	0141                	addi	sp,sp,16
    80000676:	8082                	ret
  pa = PTE2PA(*pte);
    80000678:	00a7d513          	srli	a0,a5,0xa
    8000067c:	0532                	slli	a0,a0,0xc
  return pa;
    8000067e:	bfcd                	j	80000670 <walkaddr+0x2e>
    return 0;
    80000680:	4501                	li	a0,0
    80000682:	b7fd                	j	80000670 <walkaddr+0x2e>

0000000080000684 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000684:	715d                	addi	sp,sp,-80
    80000686:	e486                	sd	ra,72(sp)
    80000688:	e0a2                	sd	s0,64(sp)
    8000068a:	fc26                	sd	s1,56(sp)
    8000068c:	f84a                	sd	s2,48(sp)
    8000068e:	f44e                	sd	s3,40(sp)
    80000690:	f052                	sd	s4,32(sp)
    80000692:	ec56                	sd	s5,24(sp)
    80000694:	e85a                	sd	s6,16(sp)
    80000696:	e45e                	sd	s7,8(sp)
    80000698:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000069a:	c205                	beqz	a2,800006ba <mappages+0x36>
    8000069c:	8aaa                	mv	s5,a0
    8000069e:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800006a0:	77fd                	lui	a5,0xfffff
    800006a2:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800006a6:	15fd                	addi	a1,a1,-1
    800006a8:	00c589b3          	add	s3,a1,a2
    800006ac:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800006b0:	8952                	mv	s2,s4
    800006b2:	41468a33          	sub	s4,a3,s4
      panic("mappages: remap");
    }
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800006b6:	6b85                	lui	s7,0x1
    800006b8:	a015                	j	800006dc <mappages+0x58>
    panic("mappages: size");
    800006ba:	00008517          	auipc	a0,0x8
    800006be:	9ce50513          	addi	a0,a0,-1586 # 80008088 <etext+0x88>
    800006c2:	00005097          	auipc	ra,0x5
    800006c6:	6a6080e7          	jalr	1702(ra) # 80005d68 <panic>
      panic("mappages: remap");
    800006ca:	00008517          	auipc	a0,0x8
    800006ce:	9ce50513          	addi	a0,a0,-1586 # 80008098 <etext+0x98>
    800006d2:	00005097          	auipc	ra,0x5
    800006d6:	696080e7          	jalr	1686(ra) # 80005d68 <panic>
    a += PGSIZE;
    800006da:	995e                	add	s2,s2,s7
  for(;;){
    800006dc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800006e0:	4605                	li	a2,1
    800006e2:	85ca                	mv	a1,s2
    800006e4:	8556                	mv	a0,s5
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	eb6080e7          	jalr	-330(ra) # 8000059c <walk>
    800006ee:	c115                	beqz	a0,80000712 <mappages+0x8e>
    if((*pte & PTE_V)&&(*pte & PTE_RSW)==0)
    800006f0:	611c                	ld	a5,0(a0)
    800006f2:	1017f793          	andi	a5,a5,257
    800006f6:	4705                	li	a4,1
    800006f8:	fce789e3          	beq	a5,a4,800006ca <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800006fc:	80b1                	srli	s1,s1,0xc
    800006fe:	04aa                	slli	s1,s1,0xa
    80000700:	0164e4b3          	or	s1,s1,s6
    80000704:	0014e493          	ori	s1,s1,1
    80000708:	e104                	sd	s1,0(a0)
    if(a == last)
    8000070a:	fd3918e3          	bne	s2,s3,800006da <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    8000070e:	4501                	li	a0,0
    80000710:	a011                	j	80000714 <mappages+0x90>
      return -1;
    80000712:	557d                	li	a0,-1
}
    80000714:	60a6                	ld	ra,72(sp)
    80000716:	6406                	ld	s0,64(sp)
    80000718:	74e2                	ld	s1,56(sp)
    8000071a:	7942                	ld	s2,48(sp)
    8000071c:	79a2                	ld	s3,40(sp)
    8000071e:	7a02                	ld	s4,32(sp)
    80000720:	6ae2                	ld	s5,24(sp)
    80000722:	6b42                	ld	s6,16(sp)
    80000724:	6ba2                	ld	s7,8(sp)
    80000726:	6161                	addi	sp,sp,80
    80000728:	8082                	ret

000000008000072a <kvmmap>:
{
    8000072a:	1141                	addi	sp,sp,-16
    8000072c:	e406                	sd	ra,8(sp)
    8000072e:	e022                	sd	s0,0(sp)
    80000730:	0800                	addi	s0,sp,16
    80000732:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000734:	86b2                	mv	a3,a2
    80000736:	863e                	mv	a2,a5
    80000738:	00000097          	auipc	ra,0x0
    8000073c:	f4c080e7          	jalr	-180(ra) # 80000684 <mappages>
    80000740:	e509                	bnez	a0,8000074a <kvmmap+0x20>
}
    80000742:	60a2                	ld	ra,8(sp)
    80000744:	6402                	ld	s0,0(sp)
    80000746:	0141                	addi	sp,sp,16
    80000748:	8082                	ret
    panic("kvmmap");
    8000074a:	00008517          	auipc	a0,0x8
    8000074e:	95e50513          	addi	a0,a0,-1698 # 800080a8 <etext+0xa8>
    80000752:	00005097          	auipc	ra,0x5
    80000756:	616080e7          	jalr	1558(ra) # 80005d68 <panic>

000000008000075a <kvmmake>:
{
    8000075a:	1101                	addi	sp,sp,-32
    8000075c:	ec06                	sd	ra,24(sp)
    8000075e:	e822                	sd	s0,16(sp)
    80000760:	e426                	sd	s1,8(sp)
    80000762:	e04a                	sd	s2,0(sp)
    80000764:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	ab8080e7          	jalr	-1352(ra) # 8000021e <kalloc>
    8000076e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000770:	6605                	lui	a2,0x1
    80000772:	4581                	li	a1,0
    80000774:	00000097          	auipc	ra,0x0
    80000778:	b40080e7          	jalr	-1216(ra) # 800002b4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000077c:	4719                	li	a4,6
    8000077e:	6685                	lui	a3,0x1
    80000780:	10000637          	lui	a2,0x10000
    80000784:	100005b7          	lui	a1,0x10000
    80000788:	8526                	mv	a0,s1
    8000078a:	00000097          	auipc	ra,0x0
    8000078e:	fa0080e7          	jalr	-96(ra) # 8000072a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000792:	4719                	li	a4,6
    80000794:	6685                	lui	a3,0x1
    80000796:	10001637          	lui	a2,0x10001
    8000079a:	100015b7          	lui	a1,0x10001
    8000079e:	8526                	mv	a0,s1
    800007a0:	00000097          	auipc	ra,0x0
    800007a4:	f8a080e7          	jalr	-118(ra) # 8000072a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800007a8:	4719                	li	a4,6
    800007aa:	004006b7          	lui	a3,0x400
    800007ae:	0c000637          	lui	a2,0xc000
    800007b2:	0c0005b7          	lui	a1,0xc000
    800007b6:	8526                	mv	a0,s1
    800007b8:	00000097          	auipc	ra,0x0
    800007bc:	f72080e7          	jalr	-142(ra) # 8000072a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800007c0:	00008917          	auipc	s2,0x8
    800007c4:	84090913          	addi	s2,s2,-1984 # 80008000 <etext>
    800007c8:	4729                	li	a4,10
    800007ca:	80008697          	auipc	a3,0x80008
    800007ce:	83668693          	addi	a3,a3,-1994 # 8000 <_entry-0x7fff8000>
    800007d2:	4605                	li	a2,1
    800007d4:	067e                	slli	a2,a2,0x1f
    800007d6:	85b2                	mv	a1,a2
    800007d8:	8526                	mv	a0,s1
    800007da:	00000097          	auipc	ra,0x0
    800007de:	f50080e7          	jalr	-176(ra) # 8000072a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800007e2:	4719                	li	a4,6
    800007e4:	46c5                	li	a3,17
    800007e6:	06ee                	slli	a3,a3,0x1b
    800007e8:	412686b3          	sub	a3,a3,s2
    800007ec:	864a                	mv	a2,s2
    800007ee:	85ca                	mv	a1,s2
    800007f0:	8526                	mv	a0,s1
    800007f2:	00000097          	auipc	ra,0x0
    800007f6:	f38080e7          	jalr	-200(ra) # 8000072a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800007fa:	4729                	li	a4,10
    800007fc:	6685                	lui	a3,0x1
    800007fe:	00007617          	auipc	a2,0x7
    80000802:	80260613          	addi	a2,a2,-2046 # 80007000 <_trampoline>
    80000806:	040005b7          	lui	a1,0x4000
    8000080a:	15fd                	addi	a1,a1,-1
    8000080c:	05b2                	slli	a1,a1,0xc
    8000080e:	8526                	mv	a0,s1
    80000810:	00000097          	auipc	ra,0x0
    80000814:	f1a080e7          	jalr	-230(ra) # 8000072a <kvmmap>
  proc_mapstacks(kpgtbl);
    80000818:	8526                	mv	a0,s1
    8000081a:	00000097          	auipc	ra,0x0
    8000081e:	640080e7          	jalr	1600(ra) # 80000e5a <proc_mapstacks>
}
    80000822:	8526                	mv	a0,s1
    80000824:	60e2                	ld	ra,24(sp)
    80000826:	6442                	ld	s0,16(sp)
    80000828:	64a2                	ld	s1,8(sp)
    8000082a:	6902                	ld	s2,0(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <kvminit>:
{
    80000830:	1141                	addi	sp,sp,-16
    80000832:	e406                	sd	ra,8(sp)
    80000834:	e022                	sd	s0,0(sp)
    80000836:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	f22080e7          	jalr	-222(ra) # 8000075a <kvmmake>
    80000840:	00008797          	auipc	a5,0x8
    80000844:	7ca7b423          	sd	a0,1992(a5) # 80009008 <kernel_pagetable>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000850:	715d                	addi	sp,sp,-80
    80000852:	e486                	sd	ra,72(sp)
    80000854:	e0a2                	sd	s0,64(sp)
    80000856:	fc26                	sd	s1,56(sp)
    80000858:	f84a                	sd	s2,48(sp)
    8000085a:	f44e                	sd	s3,40(sp)
    8000085c:	f052                	sd	s4,32(sp)
    8000085e:	ec56                	sd	s5,24(sp)
    80000860:	e85a                	sd	s6,16(sp)
    80000862:	e45e                	sd	s7,8(sp)
    80000864:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000866:	03459793          	slli	a5,a1,0x34
    8000086a:	e795                	bnez	a5,80000896 <uvmunmap+0x46>
    8000086c:	8a2a                	mv	s4,a0
    8000086e:	892e                	mv	s2,a1
    80000870:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000872:	0632                	slli	a2,a2,0xc
    80000874:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000878:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000087a:	6b05                	lui	s6,0x1
    8000087c:	0735e863          	bltu	a1,s3,800008ec <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000880:	60a6                	ld	ra,72(sp)
    80000882:	6406                	ld	s0,64(sp)
    80000884:	74e2                	ld	s1,56(sp)
    80000886:	7942                	ld	s2,48(sp)
    80000888:	79a2                	ld	s3,40(sp)
    8000088a:	7a02                	ld	s4,32(sp)
    8000088c:	6ae2                	ld	s5,24(sp)
    8000088e:	6b42                	ld	s6,16(sp)
    80000890:	6ba2                	ld	s7,8(sp)
    80000892:	6161                	addi	sp,sp,80
    80000894:	8082                	ret
    panic("uvmunmap: not aligned");
    80000896:	00008517          	auipc	a0,0x8
    8000089a:	81a50513          	addi	a0,a0,-2022 # 800080b0 <etext+0xb0>
    8000089e:	00005097          	auipc	ra,0x5
    800008a2:	4ca080e7          	jalr	1226(ra) # 80005d68 <panic>
      panic("uvmunmap: walk");
    800008a6:	00008517          	auipc	a0,0x8
    800008aa:	82250513          	addi	a0,a0,-2014 # 800080c8 <etext+0xc8>
    800008ae:	00005097          	auipc	ra,0x5
    800008b2:	4ba080e7          	jalr	1210(ra) # 80005d68 <panic>
      panic("uvmunmap: not mapped");
    800008b6:	00008517          	auipc	a0,0x8
    800008ba:	82250513          	addi	a0,a0,-2014 # 800080d8 <etext+0xd8>
    800008be:	00005097          	auipc	ra,0x5
    800008c2:	4aa080e7          	jalr	1194(ra) # 80005d68 <panic>
      panic("uvmunmap: not a leaf");
    800008c6:	00008517          	auipc	a0,0x8
    800008ca:	82a50513          	addi	a0,a0,-2006 # 800080f0 <etext+0xf0>
    800008ce:	00005097          	auipc	ra,0x5
    800008d2:	49a080e7          	jalr	1178(ra) # 80005d68 <panic>
      uint64 pa = PTE2PA(*pte);
    800008d6:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800008d8:	0532                	slli	a0,a0,0xc
    800008da:	fffff097          	auipc	ra,0xfffff
    800008de:	742080e7          	jalr	1858(ra) # 8000001c <kfree>
    *pte = 0;
    800008e2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800008e6:	995a                	add	s2,s2,s6
    800008e8:	f9397ce3          	bgeu	s2,s3,80000880 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800008ec:	4601                	li	a2,0
    800008ee:	85ca                	mv	a1,s2
    800008f0:	8552                	mv	a0,s4
    800008f2:	00000097          	auipc	ra,0x0
    800008f6:	caa080e7          	jalr	-854(ra) # 8000059c <walk>
    800008fa:	84aa                	mv	s1,a0
    800008fc:	d54d                	beqz	a0,800008a6 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800008fe:	6108                	ld	a0,0(a0)
    80000900:	00157793          	andi	a5,a0,1
    80000904:	dbcd                	beqz	a5,800008b6 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000906:	3ff57793          	andi	a5,a0,1023
    8000090a:	fb778ee3          	beq	a5,s7,800008c6 <uvmunmap+0x76>
    if(do_free){
    8000090e:	fc0a8ae3          	beqz	s5,800008e2 <uvmunmap+0x92>
    80000912:	b7d1                	j	800008d6 <uvmunmap+0x86>

0000000080000914 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000914:	1101                	addi	sp,sp,-32
    80000916:	ec06                	sd	ra,24(sp)
    80000918:	e822                	sd	s0,16(sp)
    8000091a:	e426                	sd	s1,8(sp)
    8000091c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000091e:	00000097          	auipc	ra,0x0
    80000922:	900080e7          	jalr	-1792(ra) # 8000021e <kalloc>
    80000926:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000928:	c519                	beqz	a0,80000936 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000092a:	6605                	lui	a2,0x1
    8000092c:	4581                	li	a1,0
    8000092e:	00000097          	auipc	ra,0x0
    80000932:	986080e7          	jalr	-1658(ra) # 800002b4 <memset>
  return pagetable;
}
    80000936:	8526                	mv	a0,s1
    80000938:	60e2                	ld	ra,24(sp)
    8000093a:	6442                	ld	s0,16(sp)
    8000093c:	64a2                	ld	s1,8(sp)
    8000093e:	6105                	addi	sp,sp,32
    80000940:	8082                	ret

0000000080000942 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80000942:	7179                	addi	sp,sp,-48
    80000944:	f406                	sd	ra,40(sp)
    80000946:	f022                	sd	s0,32(sp)
    80000948:	ec26                	sd	s1,24(sp)
    8000094a:	e84a                	sd	s2,16(sp)
    8000094c:	e44e                	sd	s3,8(sp)
    8000094e:	e052                	sd	s4,0(sp)
    80000950:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000952:	6785                	lui	a5,0x1
    80000954:	04f67863          	bgeu	a2,a5,800009a4 <uvminit+0x62>
    80000958:	8a2a                	mv	s4,a0
    8000095a:	89ae                	mv	s3,a1
    8000095c:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000095e:	00000097          	auipc	ra,0x0
    80000962:	8c0080e7          	jalr	-1856(ra) # 8000021e <kalloc>
    80000966:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000968:	6605                	lui	a2,0x1
    8000096a:	4581                	li	a1,0
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	948080e7          	jalr	-1720(ra) # 800002b4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000974:	4779                	li	a4,30
    80000976:	86ca                	mv	a3,s2
    80000978:	6605                	lui	a2,0x1
    8000097a:	4581                	li	a1,0
    8000097c:	8552                	mv	a0,s4
    8000097e:	00000097          	auipc	ra,0x0
    80000982:	d06080e7          	jalr	-762(ra) # 80000684 <mappages>
  memmove(mem, src, sz);
    80000986:	8626                	mv	a2,s1
    80000988:	85ce                	mv	a1,s3
    8000098a:	854a                	mv	a0,s2
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	988080e7          	jalr	-1656(ra) # 80000314 <memmove>
}
    80000994:	70a2                	ld	ra,40(sp)
    80000996:	7402                	ld	s0,32(sp)
    80000998:	64e2                	ld	s1,24(sp)
    8000099a:	6942                	ld	s2,16(sp)
    8000099c:	69a2                	ld	s3,8(sp)
    8000099e:	6a02                	ld	s4,0(sp)
    800009a0:	6145                	addi	sp,sp,48
    800009a2:	8082                	ret
    panic("inituvm: more than a page");
    800009a4:	00007517          	auipc	a0,0x7
    800009a8:	76450513          	addi	a0,a0,1892 # 80008108 <etext+0x108>
    800009ac:	00005097          	auipc	ra,0x5
    800009b0:	3bc080e7          	jalr	956(ra) # 80005d68 <panic>

00000000800009b4 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800009b4:	1101                	addi	sp,sp,-32
    800009b6:	ec06                	sd	ra,24(sp)
    800009b8:	e822                	sd	s0,16(sp)
    800009ba:	e426                	sd	s1,8(sp)
    800009bc:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800009be:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800009c0:	00b67d63          	bgeu	a2,a1,800009da <uvmdealloc+0x26>
    800009c4:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800009c6:	6785                	lui	a5,0x1
    800009c8:	17fd                	addi	a5,a5,-1
    800009ca:	00f60733          	add	a4,a2,a5
    800009ce:	767d                	lui	a2,0xfffff
    800009d0:	8f71                	and	a4,a4,a2
    800009d2:	97ae                	add	a5,a5,a1
    800009d4:	8ff1                	and	a5,a5,a2
    800009d6:	00f76863          	bltu	a4,a5,800009e6 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800009da:	8526                	mv	a0,s1
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6105                	addi	sp,sp,32
    800009e4:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800009e6:	8f99                	sub	a5,a5,a4
    800009e8:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800009ea:	4685                	li	a3,1
    800009ec:	0007861b          	sext.w	a2,a5
    800009f0:	85ba                	mv	a1,a4
    800009f2:	00000097          	auipc	ra,0x0
    800009f6:	e5e080e7          	jalr	-418(ra) # 80000850 <uvmunmap>
    800009fa:	b7c5                	j	800009da <uvmdealloc+0x26>

00000000800009fc <uvmalloc>:
  if(newsz < oldsz)
    800009fc:	0ab66163          	bltu	a2,a1,80000a9e <uvmalloc+0xa2>
{
    80000a00:	7139                	addi	sp,sp,-64
    80000a02:	fc06                	sd	ra,56(sp)
    80000a04:	f822                	sd	s0,48(sp)
    80000a06:	f426                	sd	s1,40(sp)
    80000a08:	f04a                	sd	s2,32(sp)
    80000a0a:	ec4e                	sd	s3,24(sp)
    80000a0c:	e852                	sd	s4,16(sp)
    80000a0e:	e456                	sd	s5,8(sp)
    80000a10:	0080                	addi	s0,sp,64
    80000a12:	8aaa                	mv	s5,a0
    80000a14:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000a16:	6985                	lui	s3,0x1
    80000a18:	19fd                	addi	s3,s3,-1
    80000a1a:	95ce                	add	a1,a1,s3
    80000a1c:	79fd                	lui	s3,0xfffff
    80000a1e:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a22:	08c9f063          	bgeu	s3,a2,80000aa2 <uvmalloc+0xa6>
    80000a26:	894e                	mv	s2,s3
    mem = kalloc();
    80000a28:	fffff097          	auipc	ra,0xfffff
    80000a2c:	7f6080e7          	jalr	2038(ra) # 8000021e <kalloc>
    80000a30:	84aa                	mv	s1,a0
    if(mem == 0){
    80000a32:	c51d                	beqz	a0,80000a60 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80000a34:	6605                	lui	a2,0x1
    80000a36:	4581                	li	a1,0
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	87c080e7          	jalr	-1924(ra) # 800002b4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80000a40:	4779                	li	a4,30
    80000a42:	86a6                	mv	a3,s1
    80000a44:	6605                	lui	a2,0x1
    80000a46:	85ca                	mv	a1,s2
    80000a48:	8556                	mv	a0,s5
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	c3a080e7          	jalr	-966(ra) # 80000684 <mappages>
    80000a52:	e905                	bnez	a0,80000a82 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000a54:	6785                	lui	a5,0x1
    80000a56:	993e                	add	s2,s2,a5
    80000a58:	fd4968e3          	bltu	s2,s4,80000a28 <uvmalloc+0x2c>
  return newsz;
    80000a5c:	8552                	mv	a0,s4
    80000a5e:	a809                	j	80000a70 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80000a60:	864e                	mv	a2,s3
    80000a62:	85ca                	mv	a1,s2
    80000a64:	8556                	mv	a0,s5
    80000a66:	00000097          	auipc	ra,0x0
    80000a6a:	f4e080e7          	jalr	-178(ra) # 800009b4 <uvmdealloc>
      return 0;
    80000a6e:	4501                	li	a0,0
}
    80000a70:	70e2                	ld	ra,56(sp)
    80000a72:	7442                	ld	s0,48(sp)
    80000a74:	74a2                	ld	s1,40(sp)
    80000a76:	7902                	ld	s2,32(sp)
    80000a78:	69e2                	ld	s3,24(sp)
    80000a7a:	6a42                	ld	s4,16(sp)
    80000a7c:	6aa2                	ld	s5,8(sp)
    80000a7e:	6121                	addi	sp,sp,64
    80000a80:	8082                	ret
      kfree(mem);
    80000a82:	8526                	mv	a0,s1
    80000a84:	fffff097          	auipc	ra,0xfffff
    80000a88:	598080e7          	jalr	1432(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000a8c:	864e                	mv	a2,s3
    80000a8e:	85ca                	mv	a1,s2
    80000a90:	8556                	mv	a0,s5
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	f22080e7          	jalr	-222(ra) # 800009b4 <uvmdealloc>
      return 0;
    80000a9a:	4501                	li	a0,0
    80000a9c:	bfd1                	j	80000a70 <uvmalloc+0x74>
    return oldsz;
    80000a9e:	852e                	mv	a0,a1
}
    80000aa0:	8082                	ret
  return newsz;
    80000aa2:	8532                	mv	a0,a2
    80000aa4:	b7f1                	j	80000a70 <uvmalloc+0x74>

0000000080000aa6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000aa6:	7179                	addi	sp,sp,-48
    80000aa8:	f406                	sd	ra,40(sp)
    80000aaa:	f022                	sd	s0,32(sp)
    80000aac:	ec26                	sd	s1,24(sp)
    80000aae:	e84a                	sd	s2,16(sp)
    80000ab0:	e44e                	sd	s3,8(sp)
    80000ab2:	e052                	sd	s4,0(sp)
    80000ab4:	1800                	addi	s0,sp,48
    80000ab6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000ab8:	84aa                	mv	s1,a0
    80000aba:	6905                	lui	s2,0x1
    80000abc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000abe:	4985                	li	s3,1
    80000ac0:	a821                	j	80000ad8 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000ac2:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000ac4:	0532                	slli	a0,a0,0xc
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	fe0080e7          	jalr	-32(ra) # 80000aa6 <freewalk>
      pagetable[i] = 0;
    80000ace:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000ad2:	04a1                	addi	s1,s1,8
    80000ad4:	03248163          	beq	s1,s2,80000af6 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000ad8:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000ada:	00f57793          	andi	a5,a0,15
    80000ade:	ff3782e3          	beq	a5,s3,80000ac2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000ae2:	8905                	andi	a0,a0,1
    80000ae4:	d57d                	beqz	a0,80000ad2 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000ae6:	00007517          	auipc	a0,0x7
    80000aea:	64250513          	addi	a0,a0,1602 # 80008128 <etext+0x128>
    80000aee:	00005097          	auipc	ra,0x5
    80000af2:	27a080e7          	jalr	634(ra) # 80005d68 <panic>
    }
  }
  kfree((void*)pagetable);
    80000af6:	8552                	mv	a0,s4
    80000af8:	fffff097          	auipc	ra,0xfffff
    80000afc:	524080e7          	jalr	1316(ra) # 8000001c <kfree>
}
    80000b00:	70a2                	ld	ra,40(sp)
    80000b02:	7402                	ld	s0,32(sp)
    80000b04:	64e2                	ld	s1,24(sp)
    80000b06:	6942                	ld	s2,16(sp)
    80000b08:	69a2                	ld	s3,8(sp)
    80000b0a:	6a02                	ld	s4,0(sp)
    80000b0c:	6145                	addi	sp,sp,48
    80000b0e:	8082                	ret

0000000080000b10 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000b10:	1101                	addi	sp,sp,-32
    80000b12:	ec06                	sd	ra,24(sp)
    80000b14:	e822                	sd	s0,16(sp)
    80000b16:	e426                	sd	s1,8(sp)
    80000b18:	1000                	addi	s0,sp,32
    80000b1a:	84aa                	mv	s1,a0
  if(sz > 0)
    80000b1c:	e999                	bnez	a1,80000b32 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	f86080e7          	jalr	-122(ra) # 80000aa6 <freewalk>
}
    80000b28:	60e2                	ld	ra,24(sp)
    80000b2a:	6442                	ld	s0,16(sp)
    80000b2c:	64a2                	ld	s1,8(sp)
    80000b2e:	6105                	addi	sp,sp,32
    80000b30:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000b32:	6605                	lui	a2,0x1
    80000b34:	167d                	addi	a2,a2,-1
    80000b36:	962e                	add	a2,a2,a1
    80000b38:	4685                	li	a3,1
    80000b3a:	8231                	srli	a2,a2,0xc
    80000b3c:	4581                	li	a1,0
    80000b3e:	00000097          	auipc	ra,0x0
    80000b42:	d12080e7          	jalr	-750(ra) # 80000850 <uvmunmap>
    80000b46:	bfe1                	j	80000b1e <uvmfree+0xe>

0000000080000b48 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  // char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000b48:	c271                	beqz	a2,80000c0c <uvmcopy+0xc4>
{
    80000b4a:	715d                	addi	sp,sp,-80
    80000b4c:	e486                	sd	ra,72(sp)
    80000b4e:	e0a2                	sd	s0,64(sp)
    80000b50:	fc26                	sd	s1,56(sp)
    80000b52:	f84a                	sd	s2,48(sp)
    80000b54:	f44e                	sd	s3,40(sp)
    80000b56:	f052                	sd	s4,32(sp)
    80000b58:	ec56                	sd	s5,24(sp)
    80000b5a:	e85a                	sd	s6,16(sp)
    80000b5c:	e45e                	sd	s7,8(sp)
    80000b5e:	0880                	addi	s0,sp,80
    80000b60:	8baa                	mv	s7,a0
    80000b62:	8b2e                	mv	s6,a1
    80000b64:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000b66:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    80000b68:	4601                	li	a2,0
    80000b6a:	85ca                	mv	a1,s2
    80000b6c:	855e                	mv	a0,s7
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	a2e080e7          	jalr	-1490(ra) # 8000059c <walk>
    80000b76:	84aa                	mv	s1,a0
    80000b78:	c529                	beqz	a0,80000bc2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000b7a:	00053983          	ld	s3,0(a0)
    80000b7e:	0019f793          	andi	a5,s3,1
    80000b82:	cba1                	beqz	a5,80000bd2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000b84:	00a9da13          	srli	s4,s3,0xa
    80000b88:	0a32                	slli	s4,s4,0xc

    flags = PTE_FLAGS(*pte);
    
    //Read ONLY
    //Η σελιδα ειναι και αυτην read only
    *pte &= ~PTE_W;    
    80000b8a:	ffb9f793          	andi	a5,s3,-5
    80000b8e:	e11c                	sd	a5,0(a0)
    
    //αυξανω το μετρητη της σελιδας καθω δειχνει +1 διεργασια σε αυτην
    RefPlus( pa);
    80000b90:	8552                	mv	a0,s4
    80000b92:	fffff097          	auipc	ra,0xfffff
    80000b96:	60a080e7          	jalr	1546(ra) # 8000019c <RefPlus>

    if(mappages(new, i, PGSIZE, (uint64)pa, flags) != 0){
    80000b9a:	3ff9f713          	andi	a4,s3,1023
    80000b9e:	86d2                	mv	a3,s4
    80000ba0:	6605                	lui	a2,0x1
    80000ba2:	85ca                	mv	a1,s2
    80000ba4:	855a                	mv	a0,s6
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	ade080e7          	jalr	-1314(ra) # 80000684 <mappages>
    80000bae:	e915                	bnez	a0,80000be2 <uvmcopy+0x9a>
      // kfree(mem);
      goto err;
    }

    *pte |= PTE_RSW;
    80000bb0:	609c                	ld	a5,0(s1)
    80000bb2:	1007e793          	ori	a5,a5,256
    80000bb6:	e09c                	sd	a5,0(s1)
  for(i = 0; i < sz; i += PGSIZE){
    80000bb8:	6785                	lui	a5,0x1
    80000bba:	993e                	add	s2,s2,a5
    80000bbc:	fb5966e3          	bltu	s2,s5,80000b68 <uvmcopy+0x20>
    80000bc0:	a81d                	j	80000bf6 <uvmcopy+0xae>
      panic("uvmcopy: pte should exist");
    80000bc2:	00007517          	auipc	a0,0x7
    80000bc6:	57650513          	addi	a0,a0,1398 # 80008138 <etext+0x138>
    80000bca:	00005097          	auipc	ra,0x5
    80000bce:	19e080e7          	jalr	414(ra) # 80005d68 <panic>
      panic("uvmcopy: page not present");
    80000bd2:	00007517          	auipc	a0,0x7
    80000bd6:	58650513          	addi	a0,a0,1414 # 80008158 <etext+0x158>
    80000bda:	00005097          	auipc	ra,0x5
    80000bde:	18e080e7          	jalr	398(ra) # 80005d68 <panic>

  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000be2:	4685                	li	a3,1
    80000be4:	00c95613          	srli	a2,s2,0xc
    80000be8:	4581                	li	a1,0
    80000bea:	855a                	mv	a0,s6
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	c64080e7          	jalr	-924(ra) # 80000850 <uvmunmap>
  return -1;
    80000bf4:	557d                	li	a0,-1
}
    80000bf6:	60a6                	ld	ra,72(sp)
    80000bf8:	6406                	ld	s0,64(sp)
    80000bfa:	74e2                	ld	s1,56(sp)
    80000bfc:	7942                	ld	s2,48(sp)
    80000bfe:	79a2                	ld	s3,40(sp)
    80000c00:	7a02                	ld	s4,32(sp)
    80000c02:	6ae2                	ld	s5,24(sp)
    80000c04:	6b42                	ld	s6,16(sp)
    80000c06:	6ba2                	ld	s7,8(sp)
    80000c08:	6161                	addi	sp,sp,80
    80000c0a:	8082                	ret
  return 0;
    80000c0c:	4501                	li	a0,0
}
    80000c0e:	8082                	ret

0000000080000c10 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000c10:	1141                	addi	sp,sp,-16
    80000c12:	e406                	sd	ra,8(sp)
    80000c14:	e022                	sd	s0,0(sp)
    80000c16:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000c18:	4601                	li	a2,0
    80000c1a:	00000097          	auipc	ra,0x0
    80000c1e:	982080e7          	jalr	-1662(ra) # 8000059c <walk>
  if(pte == 0)
    80000c22:	c901                	beqz	a0,80000c32 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000c24:	611c                	ld	a5,0(a0)
    80000c26:	9bbd                	andi	a5,a5,-17
    80000c28:	e11c                	sd	a5,0(a0)
}
    80000c2a:	60a2                	ld	ra,8(sp)
    80000c2c:	6402                	ld	s0,0(sp)
    80000c2e:	0141                	addi	sp,sp,16
    80000c30:	8082                	ret
    panic("uvmclear");
    80000c32:	00007517          	auipc	a0,0x7
    80000c36:	54650513          	addi	a0,a0,1350 # 80008178 <etext+0x178>
    80000c3a:	00005097          	auipc	ra,0x5
    80000c3e:	12e080e7          	jalr	302(ra) # 80005d68 <panic>

0000000080000c42 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000c42:	c6cd                	beqz	a3,80000cec <copyout+0xaa>
{
    80000c44:	711d                	addi	sp,sp,-96
    80000c46:	ec86                	sd	ra,88(sp)
    80000c48:	e8a2                	sd	s0,80(sp)
    80000c4a:	e4a6                	sd	s1,72(sp)
    80000c4c:	e0ca                	sd	s2,64(sp)
    80000c4e:	fc4e                	sd	s3,56(sp)
    80000c50:	f852                	sd	s4,48(sp)
    80000c52:	f456                	sd	s5,40(sp)
    80000c54:	f05a                	sd	s6,32(sp)
    80000c56:	ec5e                	sd	s7,24(sp)
    80000c58:	e862                	sd	s8,16(sp)
    80000c5a:	e466                	sd	s9,8(sp)
    80000c5c:	e06a                	sd	s10,0(sp)
    80000c5e:	1080                	addi	s0,sp,96
    80000c60:	8b2a                	mv	s6,a0
    80000c62:	8a2e                	mv	s4,a1
    80000c64:	8ab2                	mv	s5,a2
    80000c66:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000c68:	74fd                	lui	s1,0xfffff
    80000c6a:	8ced                	and	s1,s1,a1


    //ελεγχω το vao
    if( va0 >= MAXVA)
    80000c6c:	57fd                	li	a5,-1
    80000c6e:	83e9                	srli	a5,a5,0x1a
    80000c70:	0897e063          	bltu	a5,s1,80000cf0 <copyout+0xae>

    //αν το pte προερχεται απο cowfault
    if(*pte & PTE_RSW) 
    {
      int result = CowFoldHandler( pagetable, va0);
      if(result == -1)
    80000c74:	5cfd                	li	s9,-1
    80000c76:	6b85                	lui	s7,0x1
    if( va0 >= MAXVA)
    80000c78:	8c3e                	mv	s8,a5
    80000c7a:	a025                	j	80000ca2 <copyout+0x60>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000c7c:	409a04b3          	sub	s1,s4,s1
    80000c80:	0009061b          	sext.w	a2,s2
    80000c84:	85d6                	mv	a1,s5
    80000c86:	9526                	add	a0,a0,s1
    80000c88:	fffff097          	auipc	ra,0xfffff
    80000c8c:	68c080e7          	jalr	1676(ra) # 80000314 <memmove>
  
    
    
    len -= n;
    80000c90:	412989b3          	sub	s3,s3,s2
    src += n;
    80000c94:	9aca                	add	s5,s5,s2
  while(len > 0){
    80000c96:	04098963          	beqz	s3,80000ce8 <copyout+0xa6>
    if( va0 >= MAXVA)
    80000c9a:	05ac6d63          	bltu	s8,s10,80000cf4 <copyout+0xb2>
    va0 = PGROUNDDOWN(dstva);
    80000c9e:	84ea                	mv	s1,s10
    dstva = va0 + PGSIZE;
    80000ca0:	8a6a                	mv	s4,s10
    pte = walk(pagetable,va0,0);
    80000ca2:	4601                	li	a2,0
    80000ca4:	85a6                	mv	a1,s1
    80000ca6:	855a                	mv	a0,s6
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	8f4080e7          	jalr	-1804(ra) # 8000059c <walk>
    if(pte == 0)
    80000cb0:	c521                	beqz	a0,80000cf8 <copyout+0xb6>
    if(*pte & PTE_RSW) 
    80000cb2:	611c                	ld	a5,0(a0)
    80000cb4:	1007f793          	andi	a5,a5,256
    80000cb8:	cb89                	beqz	a5,80000cca <copyout+0x88>
      int result = CowFoldHandler( pagetable, va0);
    80000cba:	85a6                	mv	a1,s1
    80000cbc:	855a                	mv	a0,s6
    80000cbe:	00001097          	auipc	ra,0x1
    80000cc2:	f72080e7          	jalr	-142(ra) # 80001c30 <CowFoldHandler>
      if(result == -1)
    80000cc6:	03950a63          	beq	a0,s9,80000cfa <copyout+0xb8>
    pa0 = walkaddr(pagetable, va0);
    80000cca:	85a6                	mv	a1,s1
    80000ccc:	855a                	mv	a0,s6
    80000cce:	00000097          	auipc	ra,0x0
    80000cd2:	974080e7          	jalr	-1676(ra) # 80000642 <walkaddr>
    if(pa0 == 0)
    80000cd6:	c121                	beqz	a0,80000d16 <copyout+0xd4>
    n = PGSIZE - (dstva - va0);
    80000cd8:	01748d33          	add	s10,s1,s7
    80000cdc:	414d0933          	sub	s2,s10,s4
    if(n > len)
    80000ce0:	f929fee3          	bgeu	s3,s2,80000c7c <copyout+0x3a>
    80000ce4:	894e                	mv	s2,s3
    80000ce6:	bf59                	j	80000c7c <copyout+0x3a>
    
  }
  return 0;
    80000ce8:	4501                	li	a0,0
    80000cea:	a801                	j	80000cfa <copyout+0xb8>
    80000cec:	4501                	li	a0,0
}
    80000cee:	8082                	ret
      return -1;
    80000cf0:	557d                	li	a0,-1
    80000cf2:	a021                	j	80000cfa <copyout+0xb8>
    80000cf4:	557d                	li	a0,-1
    80000cf6:	a011                	j	80000cfa <copyout+0xb8>
      return -1;
    80000cf8:	557d                	li	a0,-1
}
    80000cfa:	60e6                	ld	ra,88(sp)
    80000cfc:	6446                	ld	s0,80(sp)
    80000cfe:	64a6                	ld	s1,72(sp)
    80000d00:	6906                	ld	s2,64(sp)
    80000d02:	79e2                	ld	s3,56(sp)
    80000d04:	7a42                	ld	s4,48(sp)
    80000d06:	7aa2                	ld	s5,40(sp)
    80000d08:	7b02                	ld	s6,32(sp)
    80000d0a:	6be2                	ld	s7,24(sp)
    80000d0c:	6c42                	ld	s8,16(sp)
    80000d0e:	6ca2                	ld	s9,8(sp)
    80000d10:	6d02                	ld	s10,0(sp)
    80000d12:	6125                	addi	sp,sp,96
    80000d14:	8082                	ret
      return -1;
    80000d16:	557d                	li	a0,-1
    80000d18:	b7cd                	j	80000cfa <copyout+0xb8>

0000000080000d1a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000d1a:	c6bd                	beqz	a3,80000d88 <copyin+0x6e>
{
    80000d1c:	715d                	addi	sp,sp,-80
    80000d1e:	e486                	sd	ra,72(sp)
    80000d20:	e0a2                	sd	s0,64(sp)
    80000d22:	fc26                	sd	s1,56(sp)
    80000d24:	f84a                	sd	s2,48(sp)
    80000d26:	f44e                	sd	s3,40(sp)
    80000d28:	f052                	sd	s4,32(sp)
    80000d2a:	ec56                	sd	s5,24(sp)
    80000d2c:	e85a                	sd	s6,16(sp)
    80000d2e:	e45e                	sd	s7,8(sp)
    80000d30:	e062                	sd	s8,0(sp)
    80000d32:	0880                	addi	s0,sp,80
    80000d34:	8b2a                	mv	s6,a0
    80000d36:	8a2e                	mv	s4,a1
    80000d38:	8c32                	mv	s8,a2
    80000d3a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000d3c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000d3e:	6a85                	lui	s5,0x1
    80000d40:	a015                	j	80000d64 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000d42:	9562                	add	a0,a0,s8
    80000d44:	0004861b          	sext.w	a2,s1
    80000d48:	412505b3          	sub	a1,a0,s2
    80000d4c:	8552                	mv	a0,s4
    80000d4e:	fffff097          	auipc	ra,0xfffff
    80000d52:	5c6080e7          	jalr	1478(ra) # 80000314 <memmove>

    len -= n;
    80000d56:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000d5a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000d5c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000d60:	02098263          	beqz	s3,80000d84 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000d64:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000d68:	85ca                	mv	a1,s2
    80000d6a:	855a                	mv	a0,s6
    80000d6c:	00000097          	auipc	ra,0x0
    80000d70:	8d6080e7          	jalr	-1834(ra) # 80000642 <walkaddr>
    if(pa0 == 0)
    80000d74:	cd01                	beqz	a0,80000d8c <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000d76:	418904b3          	sub	s1,s2,s8
    80000d7a:	94d6                	add	s1,s1,s5
    if(n > len)
    80000d7c:	fc99f3e3          	bgeu	s3,s1,80000d42 <copyin+0x28>
    80000d80:	84ce                	mv	s1,s3
    80000d82:	b7c1                	j	80000d42 <copyin+0x28>
  }
  return 0;
    80000d84:	4501                	li	a0,0
    80000d86:	a021                	j	80000d8e <copyin+0x74>
    80000d88:	4501                	li	a0,0
}
    80000d8a:	8082                	ret
      return -1;
    80000d8c:	557d                	li	a0,-1
}
    80000d8e:	60a6                	ld	ra,72(sp)
    80000d90:	6406                	ld	s0,64(sp)
    80000d92:	74e2                	ld	s1,56(sp)
    80000d94:	7942                	ld	s2,48(sp)
    80000d96:	79a2                	ld	s3,40(sp)
    80000d98:	7a02                	ld	s4,32(sp)
    80000d9a:	6ae2                	ld	s5,24(sp)
    80000d9c:	6b42                	ld	s6,16(sp)
    80000d9e:	6ba2                	ld	s7,8(sp)
    80000da0:	6c02                	ld	s8,0(sp)
    80000da2:	6161                	addi	sp,sp,80
    80000da4:	8082                	ret

0000000080000da6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000da6:	c6c5                	beqz	a3,80000e4e <copyinstr+0xa8>
{
    80000da8:	715d                	addi	sp,sp,-80
    80000daa:	e486                	sd	ra,72(sp)
    80000dac:	e0a2                	sd	s0,64(sp)
    80000dae:	fc26                	sd	s1,56(sp)
    80000db0:	f84a                	sd	s2,48(sp)
    80000db2:	f44e                	sd	s3,40(sp)
    80000db4:	f052                	sd	s4,32(sp)
    80000db6:	ec56                	sd	s5,24(sp)
    80000db8:	e85a                	sd	s6,16(sp)
    80000dba:	e45e                	sd	s7,8(sp)
    80000dbc:	0880                	addi	s0,sp,80
    80000dbe:	8a2a                	mv	s4,a0
    80000dc0:	8b2e                	mv	s6,a1
    80000dc2:	8bb2                	mv	s7,a2
    80000dc4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000dc6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000dc8:	6985                	lui	s3,0x1
    80000dca:	a035                	j	80000df6 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000dcc:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000dd0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000dd2:	0017b793          	seqz	a5,a5
    80000dd6:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000dda:	60a6                	ld	ra,72(sp)
    80000ddc:	6406                	ld	s0,64(sp)
    80000dde:	74e2                	ld	s1,56(sp)
    80000de0:	7942                	ld	s2,48(sp)
    80000de2:	79a2                	ld	s3,40(sp)
    80000de4:	7a02                	ld	s4,32(sp)
    80000de6:	6ae2                	ld	s5,24(sp)
    80000de8:	6b42                	ld	s6,16(sp)
    80000dea:	6ba2                	ld	s7,8(sp)
    80000dec:	6161                	addi	sp,sp,80
    80000dee:	8082                	ret
    srcva = va0 + PGSIZE;
    80000df0:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000df4:	c8a9                	beqz	s1,80000e46 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000df6:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000dfa:	85ca                	mv	a1,s2
    80000dfc:	8552                	mv	a0,s4
    80000dfe:	00000097          	auipc	ra,0x0
    80000e02:	844080e7          	jalr	-1980(ra) # 80000642 <walkaddr>
    if(pa0 == 0)
    80000e06:	c131                	beqz	a0,80000e4a <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000e08:	41790833          	sub	a6,s2,s7
    80000e0c:	984e                	add	a6,a6,s3
    if(n > max)
    80000e0e:	0104f363          	bgeu	s1,a6,80000e14 <copyinstr+0x6e>
    80000e12:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000e14:	955e                	add	a0,a0,s7
    80000e16:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000e1a:	fc080be3          	beqz	a6,80000df0 <copyinstr+0x4a>
    80000e1e:	985a                	add	a6,a6,s6
    80000e20:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000e22:	41650633          	sub	a2,a0,s6
    80000e26:	14fd                	addi	s1,s1,-1
    80000e28:	9b26                	add	s6,s6,s1
    80000e2a:	00f60733          	add	a4,a2,a5
    80000e2e:	00074703          	lbu	a4,0(a4)
    80000e32:	df49                	beqz	a4,80000dcc <copyinstr+0x26>
        *dst = *p;
    80000e34:	00e78023          	sb	a4,0(a5)
      --max;
    80000e38:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000e3c:	0785                	addi	a5,a5,1
    while(n > 0){
    80000e3e:	ff0796e3          	bne	a5,a6,80000e2a <copyinstr+0x84>
      dst++;
    80000e42:	8b42                	mv	s6,a6
    80000e44:	b775                	j	80000df0 <copyinstr+0x4a>
    80000e46:	4781                	li	a5,0
    80000e48:	b769                	j	80000dd2 <copyinstr+0x2c>
      return -1;
    80000e4a:	557d                	li	a0,-1
    80000e4c:	b779                	j	80000dda <copyinstr+0x34>
  int got_null = 0;
    80000e4e:	4781                	li	a5,0
  if(got_null){
    80000e50:	0017b793          	seqz	a5,a5
    80000e54:	40f00533          	neg	a0,a5
}
    80000e58:	8082                	ret

0000000080000e5a <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80000e5a:	7139                	addi	sp,sp,-64
    80000e5c:	fc06                	sd	ra,56(sp)
    80000e5e:	f822                	sd	s0,48(sp)
    80000e60:	f426                	sd	s1,40(sp)
    80000e62:	f04a                	sd	s2,32(sp)
    80000e64:	ec4e                	sd	s3,24(sp)
    80000e66:	e852                	sd	s4,16(sp)
    80000e68:	e456                	sd	s5,8(sp)
    80000e6a:	e05a                	sd	s6,0(sp)
    80000e6c:	0080                	addi	s0,sp,64
    80000e6e:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e70:	00228497          	auipc	s1,0x228
    80000e74:	62848493          	addi	s1,s1,1576 # 80229498 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000e78:	8b26                	mv	s6,s1
    80000e7a:	00007a97          	auipc	s5,0x7
    80000e7e:	186a8a93          	addi	s5,s5,390 # 80008000 <etext>
    80000e82:	04000937          	lui	s2,0x4000
    80000e86:	197d                	addi	s2,s2,-1
    80000e88:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e8a:	0022ea17          	auipc	s4,0x22e
    80000e8e:	00ea0a13          	addi	s4,s4,14 # 8022ee98 <tickslock>
    char *pa = kalloc();
    80000e92:	fffff097          	auipc	ra,0xfffff
    80000e96:	38c080e7          	jalr	908(ra) # 8000021e <kalloc>
    80000e9a:	862a                	mv	a2,a0
    if(pa == 0)
    80000e9c:	c131                	beqz	a0,80000ee0 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000e9e:	416485b3          	sub	a1,s1,s6
    80000ea2:	858d                	srai	a1,a1,0x3
    80000ea4:	000ab783          	ld	a5,0(s5)
    80000ea8:	02f585b3          	mul	a1,a1,a5
    80000eac:	2585                	addiw	a1,a1,1
    80000eae:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000eb2:	4719                	li	a4,6
    80000eb4:	6685                	lui	a3,0x1
    80000eb6:	40b905b3          	sub	a1,s2,a1
    80000eba:	854e                	mv	a0,s3
    80000ebc:	00000097          	auipc	ra,0x0
    80000ec0:	86e080e7          	jalr	-1938(ra) # 8000072a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ec4:	16848493          	addi	s1,s1,360
    80000ec8:	fd4495e3          	bne	s1,s4,80000e92 <proc_mapstacks+0x38>
  }
}
    80000ecc:	70e2                	ld	ra,56(sp)
    80000ece:	7442                	ld	s0,48(sp)
    80000ed0:	74a2                	ld	s1,40(sp)
    80000ed2:	7902                	ld	s2,32(sp)
    80000ed4:	69e2                	ld	s3,24(sp)
    80000ed6:	6a42                	ld	s4,16(sp)
    80000ed8:	6aa2                	ld	s5,8(sp)
    80000eda:	6b02                	ld	s6,0(sp)
    80000edc:	6121                	addi	sp,sp,64
    80000ede:	8082                	ret
      panic("kalloc");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	2a850513          	addi	a0,a0,680 # 80008188 <etext+0x188>
    80000ee8:	00005097          	auipc	ra,0x5
    80000eec:	e80080e7          	jalr	-384(ra) # 80005d68 <panic>

0000000080000ef0 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80000ef0:	7139                	addi	sp,sp,-64
    80000ef2:	fc06                	sd	ra,56(sp)
    80000ef4:	f822                	sd	s0,48(sp)
    80000ef6:	f426                	sd	s1,40(sp)
    80000ef8:	f04a                	sd	s2,32(sp)
    80000efa:	ec4e                	sd	s3,24(sp)
    80000efc:	e852                	sd	s4,16(sp)
    80000efe:	e456                	sd	s5,8(sp)
    80000f00:	e05a                	sd	s6,0(sp)
    80000f02:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000f04:	00007597          	auipc	a1,0x7
    80000f08:	28c58593          	addi	a1,a1,652 # 80008190 <etext+0x190>
    80000f0c:	00228517          	auipc	a0,0x228
    80000f10:	15c50513          	addi	a0,a0,348 # 80229068 <pid_lock>
    80000f14:	00005097          	auipc	ra,0x5
    80000f18:	30e080e7          	jalr	782(ra) # 80006222 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000f1c:	00007597          	auipc	a1,0x7
    80000f20:	27c58593          	addi	a1,a1,636 # 80008198 <etext+0x198>
    80000f24:	00228517          	auipc	a0,0x228
    80000f28:	15c50513          	addi	a0,a0,348 # 80229080 <wait_lock>
    80000f2c:	00005097          	auipc	ra,0x5
    80000f30:	2f6080e7          	jalr	758(ra) # 80006222 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f34:	00228497          	auipc	s1,0x228
    80000f38:	56448493          	addi	s1,s1,1380 # 80229498 <proc>
      initlock(&p->lock, "proc");
    80000f3c:	00007b17          	auipc	s6,0x7
    80000f40:	26cb0b13          	addi	s6,s6,620 # 800081a8 <etext+0x1a8>
      p->kstack = KSTACK((int) (p - proc));
    80000f44:	8aa6                	mv	s5,s1
    80000f46:	00007a17          	auipc	s4,0x7
    80000f4a:	0baa0a13          	addi	s4,s4,186 # 80008000 <etext>
    80000f4e:	04000937          	lui	s2,0x4000
    80000f52:	197d                	addi	s2,s2,-1
    80000f54:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f56:	0022e997          	auipc	s3,0x22e
    80000f5a:	f4298993          	addi	s3,s3,-190 # 8022ee98 <tickslock>
      initlock(&p->lock, "proc");
    80000f5e:	85da                	mv	a1,s6
    80000f60:	8526                	mv	a0,s1
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	2c0080e7          	jalr	704(ra) # 80006222 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80000f6a:	415487b3          	sub	a5,s1,s5
    80000f6e:	878d                	srai	a5,a5,0x3
    80000f70:	000a3703          	ld	a4,0(s4)
    80000f74:	02e787b3          	mul	a5,a5,a4
    80000f78:	2785                	addiw	a5,a5,1
    80000f7a:	00d7979b          	slliw	a5,a5,0xd
    80000f7e:	40f907b3          	sub	a5,s2,a5
    80000f82:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f84:	16848493          	addi	s1,s1,360
    80000f88:	fd349be3          	bne	s1,s3,80000f5e <procinit+0x6e>
  }
}
    80000f8c:	70e2                	ld	ra,56(sp)
    80000f8e:	7442                	ld	s0,48(sp)
    80000f90:	74a2                	ld	s1,40(sp)
    80000f92:	7902                	ld	s2,32(sp)
    80000f94:	69e2                	ld	s3,24(sp)
    80000f96:	6a42                	ld	s4,16(sp)
    80000f98:	6aa2                	ld	s5,8(sp)
    80000f9a:	6b02                	ld	s6,0(sp)
    80000f9c:	6121                	addi	sp,sp,64
    80000f9e:	8082                	ret

0000000080000fa0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000fa0:	1141                	addi	sp,sp,-16
    80000fa2:	e422                	sd	s0,8(sp)
    80000fa4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000fa6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000fa8:	2501                	sext.w	a0,a0
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80000fb0:	1141                	addi	sp,sp,-16
    80000fb2:	e422                	sd	s0,8(sp)
    80000fb4:	0800                	addi	s0,sp,16
    80000fb6:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000fb8:	2781                	sext.w	a5,a5
    80000fba:	079e                	slli	a5,a5,0x7
  return c;
}
    80000fbc:	00228517          	auipc	a0,0x228
    80000fc0:	0dc50513          	addi	a0,a0,220 # 80229098 <cpus>
    80000fc4:	953e                	add	a0,a0,a5
    80000fc6:	6422                	ld	s0,8(sp)
    80000fc8:	0141                	addi	sp,sp,16
    80000fca:	8082                	ret

0000000080000fcc <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80000fcc:	1101                	addi	sp,sp,-32
    80000fce:	ec06                	sd	ra,24(sp)
    80000fd0:	e822                	sd	s0,16(sp)
    80000fd2:	e426                	sd	s1,8(sp)
    80000fd4:	1000                	addi	s0,sp,32
  push_off();
    80000fd6:	00005097          	auipc	ra,0x5
    80000fda:	290080e7          	jalr	656(ra) # 80006266 <push_off>
    80000fde:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000fe0:	2781                	sext.w	a5,a5
    80000fe2:	079e                	slli	a5,a5,0x7
    80000fe4:	00228717          	auipc	a4,0x228
    80000fe8:	08470713          	addi	a4,a4,132 # 80229068 <pid_lock>
    80000fec:	97ba                	add	a5,a5,a4
    80000fee:	7b84                	ld	s1,48(a5)
  pop_off();
    80000ff0:	00005097          	auipc	ra,0x5
    80000ff4:	316080e7          	jalr	790(ra) # 80006306 <pop_off>
  return p;
}
    80000ff8:	8526                	mv	a0,s1
    80000ffa:	60e2                	ld	ra,24(sp)
    80000ffc:	6442                	ld	s0,16(sp)
    80000ffe:	64a2                	ld	s1,8(sp)
    80001000:	6105                	addi	sp,sp,32
    80001002:	8082                	ret

0000000080001004 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001004:	1141                	addi	sp,sp,-16
    80001006:	e406                	sd	ra,8(sp)
    80001008:	e022                	sd	s0,0(sp)
    8000100a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000100c:	00000097          	auipc	ra,0x0
    80001010:	fc0080e7          	jalr	-64(ra) # 80000fcc <myproc>
    80001014:	00005097          	auipc	ra,0x5
    80001018:	352080e7          	jalr	850(ra) # 80006366 <release>

  if (first) {
    8000101c:	00008797          	auipc	a5,0x8
    80001020:	8547a783          	lw	a5,-1964(a5) # 80008870 <first.1681>
    80001024:	eb89                	bnez	a5,80001036 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001026:	00001097          	auipc	ra,0x1
    8000102a:	cac080e7          	jalr	-852(ra) # 80001cd2 <usertrapret>
}
    8000102e:	60a2                	ld	ra,8(sp)
    80001030:	6402                	ld	s0,0(sp)
    80001032:	0141                	addi	sp,sp,16
    80001034:	8082                	ret
    first = 0;
    80001036:	00008797          	auipc	a5,0x8
    8000103a:	8207ad23          	sw	zero,-1990(a5) # 80008870 <first.1681>
    fsinit(ROOTDEV);
    8000103e:	4505                	li	a0,1
    80001040:	00002097          	auipc	ra,0x2
    80001044:	9f8080e7          	jalr	-1544(ra) # 80002a38 <fsinit>
    80001048:	bff9                	j	80001026 <forkret+0x22>

000000008000104a <allocpid>:
allocpid() {
    8000104a:	1101                	addi	sp,sp,-32
    8000104c:	ec06                	sd	ra,24(sp)
    8000104e:	e822                	sd	s0,16(sp)
    80001050:	e426                	sd	s1,8(sp)
    80001052:	e04a                	sd	s2,0(sp)
    80001054:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001056:	00228917          	auipc	s2,0x228
    8000105a:	01290913          	addi	s2,s2,18 # 80229068 <pid_lock>
    8000105e:	854a                	mv	a0,s2
    80001060:	00005097          	auipc	ra,0x5
    80001064:	252080e7          	jalr	594(ra) # 800062b2 <acquire>
  pid = nextpid;
    80001068:	00008797          	auipc	a5,0x8
    8000106c:	80c78793          	addi	a5,a5,-2036 # 80008874 <nextpid>
    80001070:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001072:	0014871b          	addiw	a4,s1,1
    80001076:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001078:	854a                	mv	a0,s2
    8000107a:	00005097          	auipc	ra,0x5
    8000107e:	2ec080e7          	jalr	748(ra) # 80006366 <release>
}
    80001082:	8526                	mv	a0,s1
    80001084:	60e2                	ld	ra,24(sp)
    80001086:	6442                	ld	s0,16(sp)
    80001088:	64a2                	ld	s1,8(sp)
    8000108a:	6902                	ld	s2,0(sp)
    8000108c:	6105                	addi	sp,sp,32
    8000108e:	8082                	ret

0000000080001090 <proc_pagetable>:
{
    80001090:	1101                	addi	sp,sp,-32
    80001092:	ec06                	sd	ra,24(sp)
    80001094:	e822                	sd	s0,16(sp)
    80001096:	e426                	sd	s1,8(sp)
    80001098:	e04a                	sd	s2,0(sp)
    8000109a:	1000                	addi	s0,sp,32
    8000109c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000109e:	00000097          	auipc	ra,0x0
    800010a2:	876080e7          	jalr	-1930(ra) # 80000914 <uvmcreate>
    800010a6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800010a8:	c121                	beqz	a0,800010e8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800010aa:	4729                	li	a4,10
    800010ac:	00006697          	auipc	a3,0x6
    800010b0:	f5468693          	addi	a3,a3,-172 # 80007000 <_trampoline>
    800010b4:	6605                	lui	a2,0x1
    800010b6:	040005b7          	lui	a1,0x4000
    800010ba:	15fd                	addi	a1,a1,-1
    800010bc:	05b2                	slli	a1,a1,0xc
    800010be:	fffff097          	auipc	ra,0xfffff
    800010c2:	5c6080e7          	jalr	1478(ra) # 80000684 <mappages>
    800010c6:	02054863          	bltz	a0,800010f6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800010ca:	4719                	li	a4,6
    800010cc:	05893683          	ld	a3,88(s2)
    800010d0:	6605                	lui	a2,0x1
    800010d2:	020005b7          	lui	a1,0x2000
    800010d6:	15fd                	addi	a1,a1,-1
    800010d8:	05b6                	slli	a1,a1,0xd
    800010da:	8526                	mv	a0,s1
    800010dc:	fffff097          	auipc	ra,0xfffff
    800010e0:	5a8080e7          	jalr	1448(ra) # 80000684 <mappages>
    800010e4:	02054163          	bltz	a0,80001106 <proc_pagetable+0x76>
}
    800010e8:	8526                	mv	a0,s1
    800010ea:	60e2                	ld	ra,24(sp)
    800010ec:	6442                	ld	s0,16(sp)
    800010ee:	64a2                	ld	s1,8(sp)
    800010f0:	6902                	ld	s2,0(sp)
    800010f2:	6105                	addi	sp,sp,32
    800010f4:	8082                	ret
    uvmfree(pagetable, 0);
    800010f6:	4581                	li	a1,0
    800010f8:	8526                	mv	a0,s1
    800010fa:	00000097          	auipc	ra,0x0
    800010fe:	a16080e7          	jalr	-1514(ra) # 80000b10 <uvmfree>
    return 0;
    80001102:	4481                	li	s1,0
    80001104:	b7d5                	j	800010e8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001106:	4681                	li	a3,0
    80001108:	4605                	li	a2,1
    8000110a:	040005b7          	lui	a1,0x4000
    8000110e:	15fd                	addi	a1,a1,-1
    80001110:	05b2                	slli	a1,a1,0xc
    80001112:	8526                	mv	a0,s1
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	73c080e7          	jalr	1852(ra) # 80000850 <uvmunmap>
    uvmfree(pagetable, 0);
    8000111c:	4581                	li	a1,0
    8000111e:	8526                	mv	a0,s1
    80001120:	00000097          	auipc	ra,0x0
    80001124:	9f0080e7          	jalr	-1552(ra) # 80000b10 <uvmfree>
    return 0;
    80001128:	4481                	li	s1,0
    8000112a:	bf7d                	j	800010e8 <proc_pagetable+0x58>

000000008000112c <proc_freepagetable>:
{
    8000112c:	1101                	addi	sp,sp,-32
    8000112e:	ec06                	sd	ra,24(sp)
    80001130:	e822                	sd	s0,16(sp)
    80001132:	e426                	sd	s1,8(sp)
    80001134:	e04a                	sd	s2,0(sp)
    80001136:	1000                	addi	s0,sp,32
    80001138:	84aa                	mv	s1,a0
    8000113a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000113c:	4681                	li	a3,0
    8000113e:	4605                	li	a2,1
    80001140:	040005b7          	lui	a1,0x4000
    80001144:	15fd                	addi	a1,a1,-1
    80001146:	05b2                	slli	a1,a1,0xc
    80001148:	fffff097          	auipc	ra,0xfffff
    8000114c:	708080e7          	jalr	1800(ra) # 80000850 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001150:	4681                	li	a3,0
    80001152:	4605                	li	a2,1
    80001154:	020005b7          	lui	a1,0x2000
    80001158:	15fd                	addi	a1,a1,-1
    8000115a:	05b6                	slli	a1,a1,0xd
    8000115c:	8526                	mv	a0,s1
    8000115e:	fffff097          	auipc	ra,0xfffff
    80001162:	6f2080e7          	jalr	1778(ra) # 80000850 <uvmunmap>
  uvmfree(pagetable, sz);
    80001166:	85ca                	mv	a1,s2
    80001168:	8526                	mv	a0,s1
    8000116a:	00000097          	auipc	ra,0x0
    8000116e:	9a6080e7          	jalr	-1626(ra) # 80000b10 <uvmfree>
}
    80001172:	60e2                	ld	ra,24(sp)
    80001174:	6442                	ld	s0,16(sp)
    80001176:	64a2                	ld	s1,8(sp)
    80001178:	6902                	ld	s2,0(sp)
    8000117a:	6105                	addi	sp,sp,32
    8000117c:	8082                	ret

000000008000117e <freeproc>:
{
    8000117e:	1101                	addi	sp,sp,-32
    80001180:	ec06                	sd	ra,24(sp)
    80001182:	e822                	sd	s0,16(sp)
    80001184:	e426                	sd	s1,8(sp)
    80001186:	1000                	addi	s0,sp,32
    80001188:	84aa                	mv	s1,a0
  if(p->trapframe)
    8000118a:	6d28                	ld	a0,88(a0)
    8000118c:	c509                	beqz	a0,80001196 <freeproc+0x18>
    kfree((void*)p->trapframe);
    8000118e:	fffff097          	auipc	ra,0xfffff
    80001192:	e8e080e7          	jalr	-370(ra) # 8000001c <kfree>
  p->trapframe = 0;
    80001196:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000119a:	68a8                	ld	a0,80(s1)
    8000119c:	c511                	beqz	a0,800011a8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    8000119e:	64ac                	ld	a1,72(s1)
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	f8c080e7          	jalr	-116(ra) # 8000112c <proc_freepagetable>
  p->pagetable = 0;
    800011a8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800011ac:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800011b0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800011b4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800011b8:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800011bc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800011c0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800011c4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800011c8:	0004ac23          	sw	zero,24(s1)
}
    800011cc:	60e2                	ld	ra,24(sp)
    800011ce:	6442                	ld	s0,16(sp)
    800011d0:	64a2                	ld	s1,8(sp)
    800011d2:	6105                	addi	sp,sp,32
    800011d4:	8082                	ret

00000000800011d6 <allocproc>:
{
    800011d6:	1101                	addi	sp,sp,-32
    800011d8:	ec06                	sd	ra,24(sp)
    800011da:	e822                	sd	s0,16(sp)
    800011dc:	e426                	sd	s1,8(sp)
    800011de:	e04a                	sd	s2,0(sp)
    800011e0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800011e2:	00228497          	auipc	s1,0x228
    800011e6:	2b648493          	addi	s1,s1,694 # 80229498 <proc>
    800011ea:	0022e917          	auipc	s2,0x22e
    800011ee:	cae90913          	addi	s2,s2,-850 # 8022ee98 <tickslock>
    acquire(&p->lock);
    800011f2:	8526                	mv	a0,s1
    800011f4:	00005097          	auipc	ra,0x5
    800011f8:	0be080e7          	jalr	190(ra) # 800062b2 <acquire>
    if(p->state == UNUSED) {
    800011fc:	4c9c                	lw	a5,24(s1)
    800011fe:	cf81                	beqz	a5,80001216 <allocproc+0x40>
      release(&p->lock);
    80001200:	8526                	mv	a0,s1
    80001202:	00005097          	auipc	ra,0x5
    80001206:	164080e7          	jalr	356(ra) # 80006366 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000120a:	16848493          	addi	s1,s1,360
    8000120e:	ff2492e3          	bne	s1,s2,800011f2 <allocproc+0x1c>
  return 0;
    80001212:	4481                	li	s1,0
    80001214:	a889                	j	80001266 <allocproc+0x90>
  p->pid = allocpid();
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	e34080e7          	jalr	-460(ra) # 8000104a <allocpid>
    8000121e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001220:	4785                	li	a5,1
    80001222:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	ffa080e7          	jalr	-6(ra) # 8000021e <kalloc>
    8000122c:	892a                	mv	s2,a0
    8000122e:	eca8                	sd	a0,88(s1)
    80001230:	c131                	beqz	a0,80001274 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001232:	8526                	mv	a0,s1
    80001234:	00000097          	auipc	ra,0x0
    80001238:	e5c080e7          	jalr	-420(ra) # 80001090 <proc_pagetable>
    8000123c:	892a                	mv	s2,a0
    8000123e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001240:	c531                	beqz	a0,8000128c <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001242:	07000613          	li	a2,112
    80001246:	4581                	li	a1,0
    80001248:	06048513          	addi	a0,s1,96
    8000124c:	fffff097          	auipc	ra,0xfffff
    80001250:	068080e7          	jalr	104(ra) # 800002b4 <memset>
  p->context.ra = (uint64)forkret;
    80001254:	00000797          	auipc	a5,0x0
    80001258:	db078793          	addi	a5,a5,-592 # 80001004 <forkret>
    8000125c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000125e:	60bc                	ld	a5,64(s1)
    80001260:	6705                	lui	a4,0x1
    80001262:	97ba                	add	a5,a5,a4
    80001264:	f4bc                	sd	a5,104(s1)
}
    80001266:	8526                	mv	a0,s1
    80001268:	60e2                	ld	ra,24(sp)
    8000126a:	6442                	ld	s0,16(sp)
    8000126c:	64a2                	ld	s1,8(sp)
    8000126e:	6902                	ld	s2,0(sp)
    80001270:	6105                	addi	sp,sp,32
    80001272:	8082                	ret
    freeproc(p);
    80001274:	8526                	mv	a0,s1
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	f08080e7          	jalr	-248(ra) # 8000117e <freeproc>
    release(&p->lock);
    8000127e:	8526                	mv	a0,s1
    80001280:	00005097          	auipc	ra,0x5
    80001284:	0e6080e7          	jalr	230(ra) # 80006366 <release>
    return 0;
    80001288:	84ca                	mv	s1,s2
    8000128a:	bff1                	j	80001266 <allocproc+0x90>
    freeproc(p);
    8000128c:	8526                	mv	a0,s1
    8000128e:	00000097          	auipc	ra,0x0
    80001292:	ef0080e7          	jalr	-272(ra) # 8000117e <freeproc>
    release(&p->lock);
    80001296:	8526                	mv	a0,s1
    80001298:	00005097          	auipc	ra,0x5
    8000129c:	0ce080e7          	jalr	206(ra) # 80006366 <release>
    return 0;
    800012a0:	84ca                	mv	s1,s2
    800012a2:	b7d1                	j	80001266 <allocproc+0x90>

00000000800012a4 <userinit>:
{
    800012a4:	1101                	addi	sp,sp,-32
    800012a6:	ec06                	sd	ra,24(sp)
    800012a8:	e822                	sd	s0,16(sp)
    800012aa:	e426                	sd	s1,8(sp)
    800012ac:	1000                	addi	s0,sp,32
  p = allocproc();
    800012ae:	00000097          	auipc	ra,0x0
    800012b2:	f28080e7          	jalr	-216(ra) # 800011d6 <allocproc>
    800012b6:	84aa                	mv	s1,a0
  initproc = p;
    800012b8:	00008797          	auipc	a5,0x8
    800012bc:	d4a7bc23          	sd	a0,-680(a5) # 80009010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800012c0:	03400613          	li	a2,52
    800012c4:	00007597          	auipc	a1,0x7
    800012c8:	5bc58593          	addi	a1,a1,1468 # 80008880 <initcode>
    800012cc:	6928                	ld	a0,80(a0)
    800012ce:	fffff097          	auipc	ra,0xfffff
    800012d2:	674080e7          	jalr	1652(ra) # 80000942 <uvminit>
  p->sz = PGSIZE;
    800012d6:	6785                	lui	a5,0x1
    800012d8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800012da:	6cb8                	ld	a4,88(s1)
    800012dc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800012e0:	6cb8                	ld	a4,88(s1)
    800012e2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800012e4:	4641                	li	a2,16
    800012e6:	00007597          	auipc	a1,0x7
    800012ea:	eca58593          	addi	a1,a1,-310 # 800081b0 <etext+0x1b0>
    800012ee:	15848513          	addi	a0,s1,344
    800012f2:	fffff097          	auipc	ra,0xfffff
    800012f6:	114080e7          	jalr	276(ra) # 80000406 <safestrcpy>
  p->cwd = namei("/");
    800012fa:	00007517          	auipc	a0,0x7
    800012fe:	ec650513          	addi	a0,a0,-314 # 800081c0 <etext+0x1c0>
    80001302:	00002097          	auipc	ra,0x2
    80001306:	164080e7          	jalr	356(ra) # 80003466 <namei>
    8000130a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000130e:	478d                	li	a5,3
    80001310:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001312:	8526                	mv	a0,s1
    80001314:	00005097          	auipc	ra,0x5
    80001318:	052080e7          	jalr	82(ra) # 80006366 <release>
}
    8000131c:	60e2                	ld	ra,24(sp)
    8000131e:	6442                	ld	s0,16(sp)
    80001320:	64a2                	ld	s1,8(sp)
    80001322:	6105                	addi	sp,sp,32
    80001324:	8082                	ret

0000000080001326 <growproc>:
{
    80001326:	1101                	addi	sp,sp,-32
    80001328:	ec06                	sd	ra,24(sp)
    8000132a:	e822                	sd	s0,16(sp)
    8000132c:	e426                	sd	s1,8(sp)
    8000132e:	e04a                	sd	s2,0(sp)
    80001330:	1000                	addi	s0,sp,32
    80001332:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001334:	00000097          	auipc	ra,0x0
    80001338:	c98080e7          	jalr	-872(ra) # 80000fcc <myproc>
    8000133c:	892a                	mv	s2,a0
  sz = p->sz;
    8000133e:	652c                	ld	a1,72(a0)
    80001340:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001344:	00904f63          	bgtz	s1,80001362 <growproc+0x3c>
  } else if(n < 0){
    80001348:	0204cc63          	bltz	s1,80001380 <growproc+0x5a>
  p->sz = sz;
    8000134c:	1602                	slli	a2,a2,0x20
    8000134e:	9201                	srli	a2,a2,0x20
    80001350:	04c93423          	sd	a2,72(s2)
  return 0;
    80001354:	4501                	li	a0,0
}
    80001356:	60e2                	ld	ra,24(sp)
    80001358:	6442                	ld	s0,16(sp)
    8000135a:	64a2                	ld	s1,8(sp)
    8000135c:	6902                	ld	s2,0(sp)
    8000135e:	6105                	addi	sp,sp,32
    80001360:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001362:	9e25                	addw	a2,a2,s1
    80001364:	1602                	slli	a2,a2,0x20
    80001366:	9201                	srli	a2,a2,0x20
    80001368:	1582                	slli	a1,a1,0x20
    8000136a:	9181                	srli	a1,a1,0x20
    8000136c:	6928                	ld	a0,80(a0)
    8000136e:	fffff097          	auipc	ra,0xfffff
    80001372:	68e080e7          	jalr	1678(ra) # 800009fc <uvmalloc>
    80001376:	0005061b          	sext.w	a2,a0
    8000137a:	fa69                	bnez	a2,8000134c <growproc+0x26>
      return -1;
    8000137c:	557d                	li	a0,-1
    8000137e:	bfe1                	j	80001356 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001380:	9e25                	addw	a2,a2,s1
    80001382:	1602                	slli	a2,a2,0x20
    80001384:	9201                	srli	a2,a2,0x20
    80001386:	1582                	slli	a1,a1,0x20
    80001388:	9181                	srli	a1,a1,0x20
    8000138a:	6928                	ld	a0,80(a0)
    8000138c:	fffff097          	auipc	ra,0xfffff
    80001390:	628080e7          	jalr	1576(ra) # 800009b4 <uvmdealloc>
    80001394:	0005061b          	sext.w	a2,a0
    80001398:	bf55                	j	8000134c <growproc+0x26>

000000008000139a <fork>:
{
    8000139a:	7179                	addi	sp,sp,-48
    8000139c:	f406                	sd	ra,40(sp)
    8000139e:	f022                	sd	s0,32(sp)
    800013a0:	ec26                	sd	s1,24(sp)
    800013a2:	e84a                	sd	s2,16(sp)
    800013a4:	e44e                	sd	s3,8(sp)
    800013a6:	e052                	sd	s4,0(sp)
    800013a8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	c22080e7          	jalr	-990(ra) # 80000fcc <myproc>
    800013b2:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	e22080e7          	jalr	-478(ra) # 800011d6 <allocproc>
    800013bc:	10050b63          	beqz	a0,800014d2 <fork+0x138>
    800013c0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800013c2:	04893603          	ld	a2,72(s2)
    800013c6:	692c                	ld	a1,80(a0)
    800013c8:	05093503          	ld	a0,80(s2)
    800013cc:	fffff097          	auipc	ra,0xfffff
    800013d0:	77c080e7          	jalr	1916(ra) # 80000b48 <uvmcopy>
    800013d4:	04054663          	bltz	a0,80001420 <fork+0x86>
  np->sz = p->sz;
    800013d8:	04893783          	ld	a5,72(s2)
    800013dc:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    800013e0:	05893683          	ld	a3,88(s2)
    800013e4:	87b6                	mv	a5,a3
    800013e6:	0589b703          	ld	a4,88(s3)
    800013ea:	12068693          	addi	a3,a3,288
    800013ee:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800013f2:	6788                	ld	a0,8(a5)
    800013f4:	6b8c                	ld	a1,16(a5)
    800013f6:	6f90                	ld	a2,24(a5)
    800013f8:	01073023          	sd	a6,0(a4)
    800013fc:	e708                	sd	a0,8(a4)
    800013fe:	eb0c                	sd	a1,16(a4)
    80001400:	ef10                	sd	a2,24(a4)
    80001402:	02078793          	addi	a5,a5,32
    80001406:	02070713          	addi	a4,a4,32
    8000140a:	fed792e3          	bne	a5,a3,800013ee <fork+0x54>
  np->trapframe->a0 = 0;
    8000140e:	0589b783          	ld	a5,88(s3)
    80001412:	0607b823          	sd	zero,112(a5)
    80001416:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    8000141a:	15000a13          	li	s4,336
    8000141e:	a03d                	j	8000144c <fork+0xb2>
    freeproc(np);
    80001420:	854e                	mv	a0,s3
    80001422:	00000097          	auipc	ra,0x0
    80001426:	d5c080e7          	jalr	-676(ra) # 8000117e <freeproc>
    release(&np->lock);
    8000142a:	854e                	mv	a0,s3
    8000142c:	00005097          	auipc	ra,0x5
    80001430:	f3a080e7          	jalr	-198(ra) # 80006366 <release>
    return -1;
    80001434:	5a7d                	li	s4,-1
    80001436:	a069                	j	800014c0 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    80001438:	00002097          	auipc	ra,0x2
    8000143c:	6c4080e7          	jalr	1732(ra) # 80003afc <filedup>
    80001440:	009987b3          	add	a5,s3,s1
    80001444:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001446:	04a1                	addi	s1,s1,8
    80001448:	01448763          	beq	s1,s4,80001456 <fork+0xbc>
    if(p->ofile[i])
    8000144c:	009907b3          	add	a5,s2,s1
    80001450:	6388                	ld	a0,0(a5)
    80001452:	f17d                	bnez	a0,80001438 <fork+0x9e>
    80001454:	bfcd                	j	80001446 <fork+0xac>
  np->cwd = idup(p->cwd);
    80001456:	15093503          	ld	a0,336(s2)
    8000145a:	00002097          	auipc	ra,0x2
    8000145e:	818080e7          	jalr	-2024(ra) # 80002c72 <idup>
    80001462:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001466:	4641                	li	a2,16
    80001468:	15890593          	addi	a1,s2,344
    8000146c:	15898513          	addi	a0,s3,344
    80001470:	fffff097          	auipc	ra,0xfffff
    80001474:	f96080e7          	jalr	-106(ra) # 80000406 <safestrcpy>
  pid = np->pid;
    80001478:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    8000147c:	854e                	mv	a0,s3
    8000147e:	00005097          	auipc	ra,0x5
    80001482:	ee8080e7          	jalr	-280(ra) # 80006366 <release>
  acquire(&wait_lock);
    80001486:	00228497          	auipc	s1,0x228
    8000148a:	bfa48493          	addi	s1,s1,-1030 # 80229080 <wait_lock>
    8000148e:	8526                	mv	a0,s1
    80001490:	00005097          	auipc	ra,0x5
    80001494:	e22080e7          	jalr	-478(ra) # 800062b2 <acquire>
  np->parent = p;
    80001498:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    8000149c:	8526                	mv	a0,s1
    8000149e:	00005097          	auipc	ra,0x5
    800014a2:	ec8080e7          	jalr	-312(ra) # 80006366 <release>
  acquire(&np->lock);
    800014a6:	854e                	mv	a0,s3
    800014a8:	00005097          	auipc	ra,0x5
    800014ac:	e0a080e7          	jalr	-502(ra) # 800062b2 <acquire>
  np->state = RUNNABLE;
    800014b0:	478d                	li	a5,3
    800014b2:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800014b6:	854e                	mv	a0,s3
    800014b8:	00005097          	auipc	ra,0x5
    800014bc:	eae080e7          	jalr	-338(ra) # 80006366 <release>
}
    800014c0:	8552                	mv	a0,s4
    800014c2:	70a2                	ld	ra,40(sp)
    800014c4:	7402                	ld	s0,32(sp)
    800014c6:	64e2                	ld	s1,24(sp)
    800014c8:	6942                	ld	s2,16(sp)
    800014ca:	69a2                	ld	s3,8(sp)
    800014cc:	6a02                	ld	s4,0(sp)
    800014ce:	6145                	addi	sp,sp,48
    800014d0:	8082                	ret
    return -1;
    800014d2:	5a7d                	li	s4,-1
    800014d4:	b7f5                	j	800014c0 <fork+0x126>

00000000800014d6 <scheduler>:
{
    800014d6:	7139                	addi	sp,sp,-64
    800014d8:	fc06                	sd	ra,56(sp)
    800014da:	f822                	sd	s0,48(sp)
    800014dc:	f426                	sd	s1,40(sp)
    800014de:	f04a                	sd	s2,32(sp)
    800014e0:	ec4e                	sd	s3,24(sp)
    800014e2:	e852                	sd	s4,16(sp)
    800014e4:	e456                	sd	s5,8(sp)
    800014e6:	e05a                	sd	s6,0(sp)
    800014e8:	0080                	addi	s0,sp,64
    800014ea:	8792                	mv	a5,tp
  int id = r_tp();
    800014ec:	2781                	sext.w	a5,a5
  c->proc = 0;
    800014ee:	00779a93          	slli	s5,a5,0x7
    800014f2:	00228717          	auipc	a4,0x228
    800014f6:	b7670713          	addi	a4,a4,-1162 # 80229068 <pid_lock>
    800014fa:	9756                	add	a4,a4,s5
    800014fc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001500:	00228717          	auipc	a4,0x228
    80001504:	ba070713          	addi	a4,a4,-1120 # 802290a0 <cpus+0x8>
    80001508:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000150a:	498d                	li	s3,3
        p->state = RUNNING;
    8000150c:	4b11                	li	s6,4
        c->proc = p;
    8000150e:	079e                	slli	a5,a5,0x7
    80001510:	00228a17          	auipc	s4,0x228
    80001514:	b58a0a13          	addi	s4,s4,-1192 # 80229068 <pid_lock>
    80001518:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000151a:	0022e917          	auipc	s2,0x22e
    8000151e:	97e90913          	addi	s2,s2,-1666 # 8022ee98 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001522:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001526:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000152a:	10079073          	csrw	sstatus,a5
    8000152e:	00228497          	auipc	s1,0x228
    80001532:	f6a48493          	addi	s1,s1,-150 # 80229498 <proc>
    80001536:	a03d                	j	80001564 <scheduler+0x8e>
        p->state = RUNNING;
    80001538:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000153c:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001540:	06048593          	addi	a1,s1,96
    80001544:	8556                	mv	a0,s5
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	640080e7          	jalr	1600(ra) # 80001b86 <swtch>
        c->proc = 0;
    8000154e:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001552:	8526                	mv	a0,s1
    80001554:	00005097          	auipc	ra,0x5
    80001558:	e12080e7          	jalr	-494(ra) # 80006366 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000155c:	16848493          	addi	s1,s1,360
    80001560:	fd2481e3          	beq	s1,s2,80001522 <scheduler+0x4c>
      acquire(&p->lock);
    80001564:	8526                	mv	a0,s1
    80001566:	00005097          	auipc	ra,0x5
    8000156a:	d4c080e7          	jalr	-692(ra) # 800062b2 <acquire>
      if(p->state == RUNNABLE) {
    8000156e:	4c9c                	lw	a5,24(s1)
    80001570:	ff3791e3          	bne	a5,s3,80001552 <scheduler+0x7c>
    80001574:	b7d1                	j	80001538 <scheduler+0x62>

0000000080001576 <sched>:
{
    80001576:	7179                	addi	sp,sp,-48
    80001578:	f406                	sd	ra,40(sp)
    8000157a:	f022                	sd	s0,32(sp)
    8000157c:	ec26                	sd	s1,24(sp)
    8000157e:	e84a                	sd	s2,16(sp)
    80001580:	e44e                	sd	s3,8(sp)
    80001582:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001584:	00000097          	auipc	ra,0x0
    80001588:	a48080e7          	jalr	-1464(ra) # 80000fcc <myproc>
    8000158c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000158e:	00005097          	auipc	ra,0x5
    80001592:	caa080e7          	jalr	-854(ra) # 80006238 <holding>
    80001596:	c93d                	beqz	a0,8000160c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001598:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000159a:	2781                	sext.w	a5,a5
    8000159c:	079e                	slli	a5,a5,0x7
    8000159e:	00228717          	auipc	a4,0x228
    800015a2:	aca70713          	addi	a4,a4,-1334 # 80229068 <pid_lock>
    800015a6:	97ba                	add	a5,a5,a4
    800015a8:	0a87a703          	lw	a4,168(a5)
    800015ac:	4785                	li	a5,1
    800015ae:	06f71763          	bne	a4,a5,8000161c <sched+0xa6>
  if(p->state == RUNNING)
    800015b2:	4c98                	lw	a4,24(s1)
    800015b4:	4791                	li	a5,4
    800015b6:	06f70b63          	beq	a4,a5,8000162c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800015ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800015be:	8b89                	andi	a5,a5,2
  if(intr_get())
    800015c0:	efb5                	bnez	a5,8000163c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800015c2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800015c4:	00228917          	auipc	s2,0x228
    800015c8:	aa490913          	addi	s2,s2,-1372 # 80229068 <pid_lock>
    800015cc:	2781                	sext.w	a5,a5
    800015ce:	079e                	slli	a5,a5,0x7
    800015d0:	97ca                	add	a5,a5,s2
    800015d2:	0ac7a983          	lw	s3,172(a5)
    800015d6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800015d8:	2781                	sext.w	a5,a5
    800015da:	079e                	slli	a5,a5,0x7
    800015dc:	00228597          	auipc	a1,0x228
    800015e0:	ac458593          	addi	a1,a1,-1340 # 802290a0 <cpus+0x8>
    800015e4:	95be                	add	a1,a1,a5
    800015e6:	06048513          	addi	a0,s1,96
    800015ea:	00000097          	auipc	ra,0x0
    800015ee:	59c080e7          	jalr	1436(ra) # 80001b86 <swtch>
    800015f2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800015f4:	2781                	sext.w	a5,a5
    800015f6:	079e                	slli	a5,a5,0x7
    800015f8:	97ca                	add	a5,a5,s2
    800015fa:	0b37a623          	sw	s3,172(a5)
}
    800015fe:	70a2                	ld	ra,40(sp)
    80001600:	7402                	ld	s0,32(sp)
    80001602:	64e2                	ld	s1,24(sp)
    80001604:	6942                	ld	s2,16(sp)
    80001606:	69a2                	ld	s3,8(sp)
    80001608:	6145                	addi	sp,sp,48
    8000160a:	8082                	ret
    panic("sched p->lock");
    8000160c:	00007517          	auipc	a0,0x7
    80001610:	bbc50513          	addi	a0,a0,-1092 # 800081c8 <etext+0x1c8>
    80001614:	00004097          	auipc	ra,0x4
    80001618:	754080e7          	jalr	1876(ra) # 80005d68 <panic>
    panic("sched locks");
    8000161c:	00007517          	auipc	a0,0x7
    80001620:	bbc50513          	addi	a0,a0,-1092 # 800081d8 <etext+0x1d8>
    80001624:	00004097          	auipc	ra,0x4
    80001628:	744080e7          	jalr	1860(ra) # 80005d68 <panic>
    panic("sched running");
    8000162c:	00007517          	auipc	a0,0x7
    80001630:	bbc50513          	addi	a0,a0,-1092 # 800081e8 <etext+0x1e8>
    80001634:	00004097          	auipc	ra,0x4
    80001638:	734080e7          	jalr	1844(ra) # 80005d68 <panic>
    panic("sched interruptible");
    8000163c:	00007517          	auipc	a0,0x7
    80001640:	bbc50513          	addi	a0,a0,-1092 # 800081f8 <etext+0x1f8>
    80001644:	00004097          	auipc	ra,0x4
    80001648:	724080e7          	jalr	1828(ra) # 80005d68 <panic>

000000008000164c <yield>:
{
    8000164c:	1101                	addi	sp,sp,-32
    8000164e:	ec06                	sd	ra,24(sp)
    80001650:	e822                	sd	s0,16(sp)
    80001652:	e426                	sd	s1,8(sp)
    80001654:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	976080e7          	jalr	-1674(ra) # 80000fcc <myproc>
    8000165e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001660:	00005097          	auipc	ra,0x5
    80001664:	c52080e7          	jalr	-942(ra) # 800062b2 <acquire>
  p->state = RUNNABLE;
    80001668:	478d                	li	a5,3
    8000166a:	cc9c                	sw	a5,24(s1)
  sched();
    8000166c:	00000097          	auipc	ra,0x0
    80001670:	f0a080e7          	jalr	-246(ra) # 80001576 <sched>
  release(&p->lock);
    80001674:	8526                	mv	a0,s1
    80001676:	00005097          	auipc	ra,0x5
    8000167a:	cf0080e7          	jalr	-784(ra) # 80006366 <release>
}
    8000167e:	60e2                	ld	ra,24(sp)
    80001680:	6442                	ld	s0,16(sp)
    80001682:	64a2                	ld	s1,8(sp)
    80001684:	6105                	addi	sp,sp,32
    80001686:	8082                	ret

0000000080001688 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001688:	7179                	addi	sp,sp,-48
    8000168a:	f406                	sd	ra,40(sp)
    8000168c:	f022                	sd	s0,32(sp)
    8000168e:	ec26                	sd	s1,24(sp)
    80001690:	e84a                	sd	s2,16(sp)
    80001692:	e44e                	sd	s3,8(sp)
    80001694:	1800                	addi	s0,sp,48
    80001696:	89aa                	mv	s3,a0
    80001698:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000169a:	00000097          	auipc	ra,0x0
    8000169e:	932080e7          	jalr	-1742(ra) # 80000fcc <myproc>
    800016a2:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800016a4:	00005097          	auipc	ra,0x5
    800016a8:	c0e080e7          	jalr	-1010(ra) # 800062b2 <acquire>
  release(lk);
    800016ac:	854a                	mv	a0,s2
    800016ae:	00005097          	auipc	ra,0x5
    800016b2:	cb8080e7          	jalr	-840(ra) # 80006366 <release>

  // Go to sleep.
  p->chan = chan;
    800016b6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800016ba:	4789                	li	a5,2
    800016bc:	cc9c                	sw	a5,24(s1)

  sched();
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	eb8080e7          	jalr	-328(ra) # 80001576 <sched>

  // Tidy up.
  p->chan = 0;
    800016c6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800016ca:	8526                	mv	a0,s1
    800016cc:	00005097          	auipc	ra,0x5
    800016d0:	c9a080e7          	jalr	-870(ra) # 80006366 <release>
  acquire(lk);
    800016d4:	854a                	mv	a0,s2
    800016d6:	00005097          	auipc	ra,0x5
    800016da:	bdc080e7          	jalr	-1060(ra) # 800062b2 <acquire>
}
    800016de:	70a2                	ld	ra,40(sp)
    800016e0:	7402                	ld	s0,32(sp)
    800016e2:	64e2                	ld	s1,24(sp)
    800016e4:	6942                	ld	s2,16(sp)
    800016e6:	69a2                	ld	s3,8(sp)
    800016e8:	6145                	addi	sp,sp,48
    800016ea:	8082                	ret

00000000800016ec <wait>:
{
    800016ec:	715d                	addi	sp,sp,-80
    800016ee:	e486                	sd	ra,72(sp)
    800016f0:	e0a2                	sd	s0,64(sp)
    800016f2:	fc26                	sd	s1,56(sp)
    800016f4:	f84a                	sd	s2,48(sp)
    800016f6:	f44e                	sd	s3,40(sp)
    800016f8:	f052                	sd	s4,32(sp)
    800016fa:	ec56                	sd	s5,24(sp)
    800016fc:	e85a                	sd	s6,16(sp)
    800016fe:	e45e                	sd	s7,8(sp)
    80001700:	e062                	sd	s8,0(sp)
    80001702:	0880                	addi	s0,sp,80
    80001704:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001706:	00000097          	auipc	ra,0x0
    8000170a:	8c6080e7          	jalr	-1850(ra) # 80000fcc <myproc>
    8000170e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001710:	00228517          	auipc	a0,0x228
    80001714:	97050513          	addi	a0,a0,-1680 # 80229080 <wait_lock>
    80001718:	00005097          	auipc	ra,0x5
    8000171c:	b9a080e7          	jalr	-1126(ra) # 800062b2 <acquire>
    havekids = 0;
    80001720:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80001722:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80001724:	0022d997          	auipc	s3,0x22d
    80001728:	77498993          	addi	s3,s3,1908 # 8022ee98 <tickslock>
        havekids = 1;
    8000172c:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000172e:	00228c17          	auipc	s8,0x228
    80001732:	952c0c13          	addi	s8,s8,-1710 # 80229080 <wait_lock>
    havekids = 0;
    80001736:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80001738:	00228497          	auipc	s1,0x228
    8000173c:	d6048493          	addi	s1,s1,-672 # 80229498 <proc>
    80001740:	a0bd                	j	800017ae <wait+0xc2>
          pid = np->pid;
    80001742:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80001746:	000b0e63          	beqz	s6,80001762 <wait+0x76>
    8000174a:	4691                	li	a3,4
    8000174c:	02c48613          	addi	a2,s1,44
    80001750:	85da                	mv	a1,s6
    80001752:	05093503          	ld	a0,80(s2)
    80001756:	fffff097          	auipc	ra,0xfffff
    8000175a:	4ec080e7          	jalr	1260(ra) # 80000c42 <copyout>
    8000175e:	02054563          	bltz	a0,80001788 <wait+0x9c>
          freeproc(np);
    80001762:	8526                	mv	a0,s1
    80001764:	00000097          	auipc	ra,0x0
    80001768:	a1a080e7          	jalr	-1510(ra) # 8000117e <freeproc>
          release(&np->lock);
    8000176c:	8526                	mv	a0,s1
    8000176e:	00005097          	auipc	ra,0x5
    80001772:	bf8080e7          	jalr	-1032(ra) # 80006366 <release>
          release(&wait_lock);
    80001776:	00228517          	auipc	a0,0x228
    8000177a:	90a50513          	addi	a0,a0,-1782 # 80229080 <wait_lock>
    8000177e:	00005097          	auipc	ra,0x5
    80001782:	be8080e7          	jalr	-1048(ra) # 80006366 <release>
          return pid;
    80001786:	a09d                	j	800017ec <wait+0x100>
            release(&np->lock);
    80001788:	8526                	mv	a0,s1
    8000178a:	00005097          	auipc	ra,0x5
    8000178e:	bdc080e7          	jalr	-1060(ra) # 80006366 <release>
            release(&wait_lock);
    80001792:	00228517          	auipc	a0,0x228
    80001796:	8ee50513          	addi	a0,a0,-1810 # 80229080 <wait_lock>
    8000179a:	00005097          	auipc	ra,0x5
    8000179e:	bcc080e7          	jalr	-1076(ra) # 80006366 <release>
            return -1;
    800017a2:	59fd                	li	s3,-1
    800017a4:	a0a1                	j	800017ec <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800017a6:	16848493          	addi	s1,s1,360
    800017aa:	03348463          	beq	s1,s3,800017d2 <wait+0xe6>
      if(np->parent == p){
    800017ae:	7c9c                	ld	a5,56(s1)
    800017b0:	ff279be3          	bne	a5,s2,800017a6 <wait+0xba>
        acquire(&np->lock);
    800017b4:	8526                	mv	a0,s1
    800017b6:	00005097          	auipc	ra,0x5
    800017ba:	afc080e7          	jalr	-1284(ra) # 800062b2 <acquire>
        if(np->state == ZOMBIE){
    800017be:	4c9c                	lw	a5,24(s1)
    800017c0:	f94781e3          	beq	a5,s4,80001742 <wait+0x56>
        release(&np->lock);
    800017c4:	8526                	mv	a0,s1
    800017c6:	00005097          	auipc	ra,0x5
    800017ca:	ba0080e7          	jalr	-1120(ra) # 80006366 <release>
        havekids = 1;
    800017ce:	8756                	mv	a4,s5
    800017d0:	bfd9                	j	800017a6 <wait+0xba>
    if(!havekids || p->killed){
    800017d2:	c701                	beqz	a4,800017da <wait+0xee>
    800017d4:	02892783          	lw	a5,40(s2)
    800017d8:	c79d                	beqz	a5,80001806 <wait+0x11a>
      release(&wait_lock);
    800017da:	00228517          	auipc	a0,0x228
    800017de:	8a650513          	addi	a0,a0,-1882 # 80229080 <wait_lock>
    800017e2:	00005097          	auipc	ra,0x5
    800017e6:	b84080e7          	jalr	-1148(ra) # 80006366 <release>
      return -1;
    800017ea:	59fd                	li	s3,-1
}
    800017ec:	854e                	mv	a0,s3
    800017ee:	60a6                	ld	ra,72(sp)
    800017f0:	6406                	ld	s0,64(sp)
    800017f2:	74e2                	ld	s1,56(sp)
    800017f4:	7942                	ld	s2,48(sp)
    800017f6:	79a2                	ld	s3,40(sp)
    800017f8:	7a02                	ld	s4,32(sp)
    800017fa:	6ae2                	ld	s5,24(sp)
    800017fc:	6b42                	ld	s6,16(sp)
    800017fe:	6ba2                	ld	s7,8(sp)
    80001800:	6c02                	ld	s8,0(sp)
    80001802:	6161                	addi	sp,sp,80
    80001804:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001806:	85e2                	mv	a1,s8
    80001808:	854a                	mv	a0,s2
    8000180a:	00000097          	auipc	ra,0x0
    8000180e:	e7e080e7          	jalr	-386(ra) # 80001688 <sleep>
    havekids = 0;
    80001812:	b715                	j	80001736 <wait+0x4a>

0000000080001814 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001814:	7139                	addi	sp,sp,-64
    80001816:	fc06                	sd	ra,56(sp)
    80001818:	f822                	sd	s0,48(sp)
    8000181a:	f426                	sd	s1,40(sp)
    8000181c:	f04a                	sd	s2,32(sp)
    8000181e:	ec4e                	sd	s3,24(sp)
    80001820:	e852                	sd	s4,16(sp)
    80001822:	e456                	sd	s5,8(sp)
    80001824:	0080                	addi	s0,sp,64
    80001826:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	00228497          	auipc	s1,0x228
    8000182c:	c7048493          	addi	s1,s1,-912 # 80229498 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001830:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001832:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001834:	0022d917          	auipc	s2,0x22d
    80001838:	66490913          	addi	s2,s2,1636 # 8022ee98 <tickslock>
    8000183c:	a821                	j	80001854 <wakeup+0x40>
        p->state = RUNNABLE;
    8000183e:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80001842:	8526                	mv	a0,s1
    80001844:	00005097          	auipc	ra,0x5
    80001848:	b22080e7          	jalr	-1246(ra) # 80006366 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	16848493          	addi	s1,s1,360
    80001850:	03248463          	beq	s1,s2,80001878 <wakeup+0x64>
    if(p != myproc()){
    80001854:	fffff097          	auipc	ra,0xfffff
    80001858:	778080e7          	jalr	1912(ra) # 80000fcc <myproc>
    8000185c:	fea488e3          	beq	s1,a0,8000184c <wakeup+0x38>
      acquire(&p->lock);
    80001860:	8526                	mv	a0,s1
    80001862:	00005097          	auipc	ra,0x5
    80001866:	a50080e7          	jalr	-1456(ra) # 800062b2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000186a:	4c9c                	lw	a5,24(s1)
    8000186c:	fd379be3          	bne	a5,s3,80001842 <wakeup+0x2e>
    80001870:	709c                	ld	a5,32(s1)
    80001872:	fd4798e3          	bne	a5,s4,80001842 <wakeup+0x2e>
    80001876:	b7e1                	j	8000183e <wakeup+0x2a>
    }
  }
}
    80001878:	70e2                	ld	ra,56(sp)
    8000187a:	7442                	ld	s0,48(sp)
    8000187c:	74a2                	ld	s1,40(sp)
    8000187e:	7902                	ld	s2,32(sp)
    80001880:	69e2                	ld	s3,24(sp)
    80001882:	6a42                	ld	s4,16(sp)
    80001884:	6aa2                	ld	s5,8(sp)
    80001886:	6121                	addi	sp,sp,64
    80001888:	8082                	ret

000000008000188a <reparent>:
{
    8000188a:	7179                	addi	sp,sp,-48
    8000188c:	f406                	sd	ra,40(sp)
    8000188e:	f022                	sd	s0,32(sp)
    80001890:	ec26                	sd	s1,24(sp)
    80001892:	e84a                	sd	s2,16(sp)
    80001894:	e44e                	sd	s3,8(sp)
    80001896:	e052                	sd	s4,0(sp)
    80001898:	1800                	addi	s0,sp,48
    8000189a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000189c:	00228497          	auipc	s1,0x228
    800018a0:	bfc48493          	addi	s1,s1,-1028 # 80229498 <proc>
      pp->parent = initproc;
    800018a4:	00007a17          	auipc	s4,0x7
    800018a8:	76ca0a13          	addi	s4,s4,1900 # 80009010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800018ac:	0022d997          	auipc	s3,0x22d
    800018b0:	5ec98993          	addi	s3,s3,1516 # 8022ee98 <tickslock>
    800018b4:	a029                	j	800018be <reparent+0x34>
    800018b6:	16848493          	addi	s1,s1,360
    800018ba:	01348d63          	beq	s1,s3,800018d4 <reparent+0x4a>
    if(pp->parent == p){
    800018be:	7c9c                	ld	a5,56(s1)
    800018c0:	ff279be3          	bne	a5,s2,800018b6 <reparent+0x2c>
      pp->parent = initproc;
    800018c4:	000a3503          	ld	a0,0(s4)
    800018c8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800018ca:	00000097          	auipc	ra,0x0
    800018ce:	f4a080e7          	jalr	-182(ra) # 80001814 <wakeup>
    800018d2:	b7d5                	j	800018b6 <reparent+0x2c>
}
    800018d4:	70a2                	ld	ra,40(sp)
    800018d6:	7402                	ld	s0,32(sp)
    800018d8:	64e2                	ld	s1,24(sp)
    800018da:	6942                	ld	s2,16(sp)
    800018dc:	69a2                	ld	s3,8(sp)
    800018de:	6a02                	ld	s4,0(sp)
    800018e0:	6145                	addi	sp,sp,48
    800018e2:	8082                	ret

00000000800018e4 <exit>:
{
    800018e4:	7179                	addi	sp,sp,-48
    800018e6:	f406                	sd	ra,40(sp)
    800018e8:	f022                	sd	s0,32(sp)
    800018ea:	ec26                	sd	s1,24(sp)
    800018ec:	e84a                	sd	s2,16(sp)
    800018ee:	e44e                	sd	s3,8(sp)
    800018f0:	e052                	sd	s4,0(sp)
    800018f2:	1800                	addi	s0,sp,48
    800018f4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	6d6080e7          	jalr	1750(ra) # 80000fcc <myproc>
    800018fe:	89aa                	mv	s3,a0
  if(p == initproc)
    80001900:	00007797          	auipc	a5,0x7
    80001904:	7107b783          	ld	a5,1808(a5) # 80009010 <initproc>
    80001908:	0d050493          	addi	s1,a0,208
    8000190c:	15050913          	addi	s2,a0,336
    80001910:	02a79363          	bne	a5,a0,80001936 <exit+0x52>
    panic("init exiting");
    80001914:	00007517          	auipc	a0,0x7
    80001918:	8fc50513          	addi	a0,a0,-1796 # 80008210 <etext+0x210>
    8000191c:	00004097          	auipc	ra,0x4
    80001920:	44c080e7          	jalr	1100(ra) # 80005d68 <panic>
      fileclose(f);
    80001924:	00002097          	auipc	ra,0x2
    80001928:	22a080e7          	jalr	554(ra) # 80003b4e <fileclose>
      p->ofile[fd] = 0;
    8000192c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001930:	04a1                	addi	s1,s1,8
    80001932:	01248563          	beq	s1,s2,8000193c <exit+0x58>
    if(p->ofile[fd]){
    80001936:	6088                	ld	a0,0(s1)
    80001938:	f575                	bnez	a0,80001924 <exit+0x40>
    8000193a:	bfdd                	j	80001930 <exit+0x4c>
  begin_op();
    8000193c:	00002097          	auipc	ra,0x2
    80001940:	d46080e7          	jalr	-698(ra) # 80003682 <begin_op>
  iput(p->cwd);
    80001944:	1509b503          	ld	a0,336(s3)
    80001948:	00001097          	auipc	ra,0x1
    8000194c:	522080e7          	jalr	1314(ra) # 80002e6a <iput>
  end_op();
    80001950:	00002097          	auipc	ra,0x2
    80001954:	db2080e7          	jalr	-590(ra) # 80003702 <end_op>
  p->cwd = 0;
    80001958:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000195c:	00227497          	auipc	s1,0x227
    80001960:	72448493          	addi	s1,s1,1828 # 80229080 <wait_lock>
    80001964:	8526                	mv	a0,s1
    80001966:	00005097          	auipc	ra,0x5
    8000196a:	94c080e7          	jalr	-1716(ra) # 800062b2 <acquire>
  reparent(p);
    8000196e:	854e                	mv	a0,s3
    80001970:	00000097          	auipc	ra,0x0
    80001974:	f1a080e7          	jalr	-230(ra) # 8000188a <reparent>
  wakeup(p->parent);
    80001978:	0389b503          	ld	a0,56(s3)
    8000197c:	00000097          	auipc	ra,0x0
    80001980:	e98080e7          	jalr	-360(ra) # 80001814 <wakeup>
  acquire(&p->lock);
    80001984:	854e                	mv	a0,s3
    80001986:	00005097          	auipc	ra,0x5
    8000198a:	92c080e7          	jalr	-1748(ra) # 800062b2 <acquire>
  p->xstate = status;
    8000198e:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001992:	4795                	li	a5,5
    80001994:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001998:	8526                	mv	a0,s1
    8000199a:	00005097          	auipc	ra,0x5
    8000199e:	9cc080e7          	jalr	-1588(ra) # 80006366 <release>
  sched();
    800019a2:	00000097          	auipc	ra,0x0
    800019a6:	bd4080e7          	jalr	-1068(ra) # 80001576 <sched>
  panic("zombie exit");
    800019aa:	00007517          	auipc	a0,0x7
    800019ae:	87650513          	addi	a0,a0,-1930 # 80008220 <etext+0x220>
    800019b2:	00004097          	auipc	ra,0x4
    800019b6:	3b6080e7          	jalr	950(ra) # 80005d68 <panic>

00000000800019ba <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800019ba:	7179                	addi	sp,sp,-48
    800019bc:	f406                	sd	ra,40(sp)
    800019be:	f022                	sd	s0,32(sp)
    800019c0:	ec26                	sd	s1,24(sp)
    800019c2:	e84a                	sd	s2,16(sp)
    800019c4:	e44e                	sd	s3,8(sp)
    800019c6:	1800                	addi	s0,sp,48
    800019c8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800019ca:	00228497          	auipc	s1,0x228
    800019ce:	ace48493          	addi	s1,s1,-1330 # 80229498 <proc>
    800019d2:	0022d997          	auipc	s3,0x22d
    800019d6:	4c698993          	addi	s3,s3,1222 # 8022ee98 <tickslock>
    acquire(&p->lock);
    800019da:	8526                	mv	a0,s1
    800019dc:	00005097          	auipc	ra,0x5
    800019e0:	8d6080e7          	jalr	-1834(ra) # 800062b2 <acquire>
    if(p->pid == pid){
    800019e4:	589c                	lw	a5,48(s1)
    800019e6:	01278d63          	beq	a5,s2,80001a00 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800019ea:	8526                	mv	a0,s1
    800019ec:	00005097          	auipc	ra,0x5
    800019f0:	97a080e7          	jalr	-1670(ra) # 80006366 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800019f4:	16848493          	addi	s1,s1,360
    800019f8:	ff3491e3          	bne	s1,s3,800019da <kill+0x20>
  }
  return -1;
    800019fc:	557d                	li	a0,-1
    800019fe:	a829                	j	80001a18 <kill+0x5e>
      p->killed = 1;
    80001a00:	4785                	li	a5,1
    80001a02:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001a04:	4c98                	lw	a4,24(s1)
    80001a06:	4789                	li	a5,2
    80001a08:	00f70f63          	beq	a4,a5,80001a26 <kill+0x6c>
      release(&p->lock);
    80001a0c:	8526                	mv	a0,s1
    80001a0e:	00005097          	auipc	ra,0x5
    80001a12:	958080e7          	jalr	-1704(ra) # 80006366 <release>
      return 0;
    80001a16:	4501                	li	a0,0
}
    80001a18:	70a2                	ld	ra,40(sp)
    80001a1a:	7402                	ld	s0,32(sp)
    80001a1c:	64e2                	ld	s1,24(sp)
    80001a1e:	6942                	ld	s2,16(sp)
    80001a20:	69a2                	ld	s3,8(sp)
    80001a22:	6145                	addi	sp,sp,48
    80001a24:	8082                	ret
        p->state = RUNNABLE;
    80001a26:	478d                	li	a5,3
    80001a28:	cc9c                	sw	a5,24(s1)
    80001a2a:	b7cd                	j	80001a0c <kill+0x52>

0000000080001a2c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001a2c:	7179                	addi	sp,sp,-48
    80001a2e:	f406                	sd	ra,40(sp)
    80001a30:	f022                	sd	s0,32(sp)
    80001a32:	ec26                	sd	s1,24(sp)
    80001a34:	e84a                	sd	s2,16(sp)
    80001a36:	e44e                	sd	s3,8(sp)
    80001a38:	e052                	sd	s4,0(sp)
    80001a3a:	1800                	addi	s0,sp,48
    80001a3c:	84aa                	mv	s1,a0
    80001a3e:	892e                	mv	s2,a1
    80001a40:	89b2                	mv	s3,a2
    80001a42:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	588080e7          	jalr	1416(ra) # 80000fcc <myproc>
  if(user_dst){
    80001a4c:	c08d                	beqz	s1,80001a6e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001a4e:	86d2                	mv	a3,s4
    80001a50:	864e                	mv	a2,s3
    80001a52:	85ca                	mv	a1,s2
    80001a54:	6928                	ld	a0,80(a0)
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	1ec080e7          	jalr	492(ra) # 80000c42 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001a5e:	70a2                	ld	ra,40(sp)
    80001a60:	7402                	ld	s0,32(sp)
    80001a62:	64e2                	ld	s1,24(sp)
    80001a64:	6942                	ld	s2,16(sp)
    80001a66:	69a2                	ld	s3,8(sp)
    80001a68:	6a02                	ld	s4,0(sp)
    80001a6a:	6145                	addi	sp,sp,48
    80001a6c:	8082                	ret
    memmove((char *)dst, src, len);
    80001a6e:	000a061b          	sext.w	a2,s4
    80001a72:	85ce                	mv	a1,s3
    80001a74:	854a                	mv	a0,s2
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	89e080e7          	jalr	-1890(ra) # 80000314 <memmove>
    return 0;
    80001a7e:	8526                	mv	a0,s1
    80001a80:	bff9                	j	80001a5e <either_copyout+0x32>

0000000080001a82 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001a82:	7179                	addi	sp,sp,-48
    80001a84:	f406                	sd	ra,40(sp)
    80001a86:	f022                	sd	s0,32(sp)
    80001a88:	ec26                	sd	s1,24(sp)
    80001a8a:	e84a                	sd	s2,16(sp)
    80001a8c:	e44e                	sd	s3,8(sp)
    80001a8e:	e052                	sd	s4,0(sp)
    80001a90:	1800                	addi	s0,sp,48
    80001a92:	892a                	mv	s2,a0
    80001a94:	84ae                	mv	s1,a1
    80001a96:	89b2                	mv	s3,a2
    80001a98:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001a9a:	fffff097          	auipc	ra,0xfffff
    80001a9e:	532080e7          	jalr	1330(ra) # 80000fcc <myproc>
  if(user_src){
    80001aa2:	c08d                	beqz	s1,80001ac4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001aa4:	86d2                	mv	a3,s4
    80001aa6:	864e                	mv	a2,s3
    80001aa8:	85ca                	mv	a1,s2
    80001aaa:	6928                	ld	a0,80(a0)
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	26e080e7          	jalr	622(ra) # 80000d1a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001ab4:	70a2                	ld	ra,40(sp)
    80001ab6:	7402                	ld	s0,32(sp)
    80001ab8:	64e2                	ld	s1,24(sp)
    80001aba:	6942                	ld	s2,16(sp)
    80001abc:	69a2                	ld	s3,8(sp)
    80001abe:	6a02                	ld	s4,0(sp)
    80001ac0:	6145                	addi	sp,sp,48
    80001ac2:	8082                	ret
    memmove(dst, (char*)src, len);
    80001ac4:	000a061b          	sext.w	a2,s4
    80001ac8:	85ce                	mv	a1,s3
    80001aca:	854a                	mv	a0,s2
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	848080e7          	jalr	-1976(ra) # 80000314 <memmove>
    return 0;
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	bff9                	j	80001ab4 <either_copyin+0x32>

0000000080001ad8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001ad8:	715d                	addi	sp,sp,-80
    80001ada:	e486                	sd	ra,72(sp)
    80001adc:	e0a2                	sd	s0,64(sp)
    80001ade:	fc26                	sd	s1,56(sp)
    80001ae0:	f84a                	sd	s2,48(sp)
    80001ae2:	f44e                	sd	s3,40(sp)
    80001ae4:	f052                	sd	s4,32(sp)
    80001ae6:	ec56                	sd	s5,24(sp)
    80001ae8:	e85a                	sd	s6,16(sp)
    80001aea:	e45e                	sd	s7,8(sp)
    80001aec:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001aee:	00006517          	auipc	a0,0x6
    80001af2:	58a50513          	addi	a0,a0,1418 # 80008078 <etext+0x78>
    80001af6:	00004097          	auipc	ra,0x4
    80001afa:	2bc080e7          	jalr	700(ra) # 80005db2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001afe:	00228497          	auipc	s1,0x228
    80001b02:	af248493          	addi	s1,s1,-1294 # 802295f0 <proc+0x158>
    80001b06:	0022d917          	auipc	s2,0x22d
    80001b0a:	4ea90913          	addi	s2,s2,1258 # 8022eff0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b0e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001b10:	00006997          	auipc	s3,0x6
    80001b14:	72098993          	addi	s3,s3,1824 # 80008230 <etext+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    80001b18:	00006a97          	auipc	s5,0x6
    80001b1c:	720a8a93          	addi	s5,s5,1824 # 80008238 <etext+0x238>
    printf("\n");
    80001b20:	00006a17          	auipc	s4,0x6
    80001b24:	558a0a13          	addi	s4,s4,1368 # 80008078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b28:	00006b97          	auipc	s7,0x6
    80001b2c:	748b8b93          	addi	s7,s7,1864 # 80008270 <states.1718>
    80001b30:	a00d                	j	80001b52 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001b32:	ed86a583          	lw	a1,-296(a3)
    80001b36:	8556                	mv	a0,s5
    80001b38:	00004097          	auipc	ra,0x4
    80001b3c:	27a080e7          	jalr	634(ra) # 80005db2 <printf>
    printf("\n");
    80001b40:	8552                	mv	a0,s4
    80001b42:	00004097          	auipc	ra,0x4
    80001b46:	270080e7          	jalr	624(ra) # 80005db2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001b4a:	16848493          	addi	s1,s1,360
    80001b4e:	03248163          	beq	s1,s2,80001b70 <procdump+0x98>
    if(p->state == UNUSED)
    80001b52:	86a6                	mv	a3,s1
    80001b54:	ec04a783          	lw	a5,-320(s1)
    80001b58:	dbed                	beqz	a5,80001b4a <procdump+0x72>
      state = "???";
    80001b5a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001b5c:	fcfb6be3          	bltu	s6,a5,80001b32 <procdump+0x5a>
    80001b60:	1782                	slli	a5,a5,0x20
    80001b62:	9381                	srli	a5,a5,0x20
    80001b64:	078e                	slli	a5,a5,0x3
    80001b66:	97de                	add	a5,a5,s7
    80001b68:	6390                	ld	a2,0(a5)
    80001b6a:	f661                	bnez	a2,80001b32 <procdump+0x5a>
      state = "???";
    80001b6c:	864e                	mv	a2,s3
    80001b6e:	b7d1                	j	80001b32 <procdump+0x5a>
  }
}
    80001b70:	60a6                	ld	ra,72(sp)
    80001b72:	6406                	ld	s0,64(sp)
    80001b74:	74e2                	ld	s1,56(sp)
    80001b76:	7942                	ld	s2,48(sp)
    80001b78:	79a2                	ld	s3,40(sp)
    80001b7a:	7a02                	ld	s4,32(sp)
    80001b7c:	6ae2                	ld	s5,24(sp)
    80001b7e:	6b42                	ld	s6,16(sp)
    80001b80:	6ba2                	ld	s7,8(sp)
    80001b82:	6161                	addi	sp,sp,80
    80001b84:	8082                	ret

0000000080001b86 <swtch>:
    80001b86:	00153023          	sd	ra,0(a0)
    80001b8a:	00253423          	sd	sp,8(a0)
    80001b8e:	e900                	sd	s0,16(a0)
    80001b90:	ed04                	sd	s1,24(a0)
    80001b92:	03253023          	sd	s2,32(a0)
    80001b96:	03353423          	sd	s3,40(a0)
    80001b9a:	03453823          	sd	s4,48(a0)
    80001b9e:	03553c23          	sd	s5,56(a0)
    80001ba2:	05653023          	sd	s6,64(a0)
    80001ba6:	05753423          	sd	s7,72(a0)
    80001baa:	05853823          	sd	s8,80(a0)
    80001bae:	05953c23          	sd	s9,88(a0)
    80001bb2:	07a53023          	sd	s10,96(a0)
    80001bb6:	07b53423          	sd	s11,104(a0)
    80001bba:	0005b083          	ld	ra,0(a1)
    80001bbe:	0085b103          	ld	sp,8(a1)
    80001bc2:	6980                	ld	s0,16(a1)
    80001bc4:	6d84                	ld	s1,24(a1)
    80001bc6:	0205b903          	ld	s2,32(a1)
    80001bca:	0285b983          	ld	s3,40(a1)
    80001bce:	0305ba03          	ld	s4,48(a1)
    80001bd2:	0385ba83          	ld	s5,56(a1)
    80001bd6:	0405bb03          	ld	s6,64(a1)
    80001bda:	0485bb83          	ld	s7,72(a1)
    80001bde:	0505bc03          	ld	s8,80(a1)
    80001be2:	0585bc83          	ld	s9,88(a1)
    80001be6:	0605bd03          	ld	s10,96(a1)
    80001bea:	0685bd83          	ld	s11,104(a1)
    80001bee:	8082                	ret

0000000080001bf0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001bf0:	1141                	addi	sp,sp,-16
    80001bf2:	e406                	sd	ra,8(sp)
    80001bf4:	e022                	sd	s0,0(sp)
    80001bf6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001bf8:	00006597          	auipc	a1,0x6
    80001bfc:	6a858593          	addi	a1,a1,1704 # 800082a0 <states.1718+0x30>
    80001c00:	0022d517          	auipc	a0,0x22d
    80001c04:	29850513          	addi	a0,a0,664 # 8022ee98 <tickslock>
    80001c08:	00004097          	auipc	ra,0x4
    80001c0c:	61a080e7          	jalr	1562(ra) # 80006222 <initlock>
}
    80001c10:	60a2                	ld	ra,8(sp)
    80001c12:	6402                	ld	s0,0(sp)
    80001c14:	0141                	addi	sp,sp,16
    80001c16:	8082                	ret

0000000080001c18 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001c18:	1141                	addi	sp,sp,-16
    80001c1a:	e422                	sd	s0,8(sp)
    80001c1c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c1e:	00003797          	auipc	a5,0x3
    80001c22:	55278793          	addi	a5,a5,1362 # 80005170 <kernelvec>
    80001c26:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001c2a:	6422                	ld	s0,8(sp)
    80001c2c:	0141                	addi	sp,sp,16
    80001c2e:	8082                	ret

0000000080001c30 <CowFoldHandler>:
int CowFoldHandler( pagetable_t pa, uint64 r)
{
  pte_t *pte;
 
  //Αν ειναι μεγαλυτερο του Maxva
  if( r >= MAXVA)
    80001c30:	57fd                	li	a5,-1
    80001c32:	83e9                	srli	a5,a5,0x1a
    80001c34:	08b7e563          	bltu	a5,a1,80001cbe <CowFoldHandler+0x8e>
{
    80001c38:	7179                	addi	sp,sp,-48
    80001c3a:	f406                	sd	ra,40(sp)
    80001c3c:	f022                	sd	s0,32(sp)
    80001c3e:	ec26                	sd	s1,24(sp)
    80001c40:	e84a                	sd	s2,16(sp)
    80001c42:	e44e                	sd	s3,8(sp)
    80001c44:	1800                	addi	s0,sp,48
    80001c46:	84aa                	mv	s1,a0
  {
    return -1;
  }

  //παιρνει το pte
  if( (pte = walk( pa, r, 0)) == 0)
    80001c48:	4601                	li	a2,0
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	952080e7          	jalr	-1710(ra) # 8000059c <walk>
    80001c52:	89aa                	mv	s3,a0
    80001c54:	cd29                	beqz	a0,80001cae <CowFoldHandler+0x7e>
    panic("CowFoldHandler: pte should exist");
  
  //αν ειναι εγκυρο
  if((*pte & PTE_V) == 0)
    80001c56:	610c                	ld	a1,0(a0)
    return -1;

  //αν ειναι user
  if((*pte & PTE_U) == 0)
    80001c58:	0115f713          	andi	a4,a1,17
    80001c5c:	47c5                	li	a5,17
    80001c5e:	06f71263          	bne	a4,a5,80001cc2 <CowFoldHandler+0x92>
    return -1; 

  //αν το pte μας προρχεται απο cowfault
  if((*pte & PTE_RSW) == 0) 
    80001c62:	1005f793          	andi	a5,a1,256
    80001c66:	c3a5                	beqz	a5,80001cc6 <CowFoldHandler+0x96>
  {
    return -1;
  }
  
  if( pa == 0)
    80001c68:	c0ad                	beqz	s1,80001cca <CowFoldHandler+0x9a>
    return -1;

  uint64 pa_2;
  pa_2 = PTE2PA(*pte);
    80001c6a:	81a9                	srli	a1,a1,0xa
    80001c6c:	00c59913          	slli	s2,a1,0xc
  
  //δεσμευω την καινουρια
  uint64 pa_new;
  pa_new = (uint64)kalloc();
    80001c70:	ffffe097          	auipc	ra,0xffffe
    80001c74:	5ae080e7          	jalr	1454(ra) # 8000021e <kalloc>
    80001c78:	84aa                	mv	s1,a0
  if (pa_new == 0)
    80001c7a:	c931                	beqz	a0,80001cce <CowFoldHandler+0x9e>
    return -1;

  //αντιγραφη των δεδομενων στην καινουρια σελιδας
  memmove( (void*)pa_new, (void*)pa_2, PGSIZE);
    80001c7c:	6605                	lui	a2,0x1
    80001c7e:	85ca                	mv	a1,s2
    80001c80:	ffffe097          	auipc	ra,0xffffe
    80001c84:	694080e7          	jalr	1684(ra) # 80000314 <memmove>

  *pte = PA2PTE( pa_new)|PTE_R|PTE_W|PTE_V|PTE_U|PTE_X|PTE_RSW;
    80001c88:	80b1                	srli	s1,s1,0xc
    80001c8a:	04aa                	slli	s1,s1,0xa
    80001c8c:	11f4e493          	ori	s1,s1,287
    80001c90:	0099b023          	sd	s1,0(s3)


  //Καλω την kfree για την δοθεισα σελιδα ωστε να μειωθει το counter και αν το counter 
  //μετα την μειωση του ειναι μηδεν τοτε αποδεσμευω την σελιδα
  kfree( (void*)pa_2);
    80001c94:	854a                	mv	a0,s2
    80001c96:	ffffe097          	auipc	ra,0xffffe
    80001c9a:	386080e7          	jalr	902(ra) # 8000001c <kfree>
  return 0;
    80001c9e:	4501                	li	a0,0

}
    80001ca0:	70a2                	ld	ra,40(sp)
    80001ca2:	7402                	ld	s0,32(sp)
    80001ca4:	64e2                	ld	s1,24(sp)
    80001ca6:	6942                	ld	s2,16(sp)
    80001ca8:	69a2                	ld	s3,8(sp)
    80001caa:	6145                	addi	sp,sp,48
    80001cac:	8082                	ret
    panic("CowFoldHandler: pte should exist");
    80001cae:	00006517          	auipc	a0,0x6
    80001cb2:	5fa50513          	addi	a0,a0,1530 # 800082a8 <states.1718+0x38>
    80001cb6:	00004097          	auipc	ra,0x4
    80001cba:	0b2080e7          	jalr	178(ra) # 80005d68 <panic>
    return -1;
    80001cbe:	557d                	li	a0,-1
}
    80001cc0:	8082                	ret
    return -1; 
    80001cc2:	557d                	li	a0,-1
    80001cc4:	bff1                	j	80001ca0 <CowFoldHandler+0x70>
    return -1;
    80001cc6:	557d                	li	a0,-1
    80001cc8:	bfe1                	j	80001ca0 <CowFoldHandler+0x70>
    return -1;
    80001cca:	557d                	li	a0,-1
    80001ccc:	bfd1                	j	80001ca0 <CowFoldHandler+0x70>
    return -1;
    80001cce:	557d                	li	a0,-1
    80001cd0:	bfc1                	j	80001ca0 <CowFoldHandler+0x70>

0000000080001cd2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001cd2:	1141                	addi	sp,sp,-16
    80001cd4:	e406                	sd	ra,8(sp)
    80001cd6:	e022                	sd	s0,0(sp)
    80001cd8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	2f2080e7          	jalr	754(ra) # 80000fcc <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ce2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001ce6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ce8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80001cec:	00005617          	auipc	a2,0x5
    80001cf0:	31460613          	addi	a2,a2,788 # 80007000 <_trampoline>
    80001cf4:	00005697          	auipc	a3,0x5
    80001cf8:	30c68693          	addi	a3,a3,780 # 80007000 <_trampoline>
    80001cfc:	8e91                	sub	a3,a3,a2
    80001cfe:	040007b7          	lui	a5,0x4000
    80001d02:	17fd                	addi	a5,a5,-1
    80001d04:	07b2                	slli	a5,a5,0xc
    80001d06:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d08:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001d0c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001d0e:	180026f3          	csrr	a3,satp
    80001d12:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001d14:	6d38                	ld	a4,88(a0)
    80001d16:	6134                	ld	a3,64(a0)
    80001d18:	6585                	lui	a1,0x1
    80001d1a:	96ae                	add	a3,a3,a1
    80001d1c:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001d1e:	6d38                	ld	a4,88(a0)
    80001d20:	00000697          	auipc	a3,0x0
    80001d24:	13868693          	addi	a3,a3,312 # 80001e58 <usertrap>
    80001d28:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001d2a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d2c:	8692                	mv	a3,tp
    80001d2e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d30:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001d34:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001d38:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d3c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001d40:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001d42:	6f18                	ld	a4,24(a4)
    80001d44:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001d48:	692c                	ld	a1,80(a0)
    80001d4a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80001d4c:	00005717          	auipc	a4,0x5
    80001d50:	34470713          	addi	a4,a4,836 # 80007090 <userret>
    80001d54:	8f11                	sub	a4,a4,a2
    80001d56:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80001d58:	577d                	li	a4,-1
    80001d5a:	177e                	slli	a4,a4,0x3f
    80001d5c:	8dd9                	or	a1,a1,a4
    80001d5e:	02000537          	lui	a0,0x2000
    80001d62:	157d                	addi	a0,a0,-1
    80001d64:	0536                	slli	a0,a0,0xd
    80001d66:	9782                	jalr	a5
}
    80001d68:	60a2                	ld	ra,8(sp)
    80001d6a:	6402                	ld	s0,0(sp)
    80001d6c:	0141                	addi	sp,sp,16
    80001d6e:	8082                	ret

0000000080001d70 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001d7a:	0022d497          	auipc	s1,0x22d
    80001d7e:	11e48493          	addi	s1,s1,286 # 8022ee98 <tickslock>
    80001d82:	8526                	mv	a0,s1
    80001d84:	00004097          	auipc	ra,0x4
    80001d88:	52e080e7          	jalr	1326(ra) # 800062b2 <acquire>
  ticks++;
    80001d8c:	00007517          	auipc	a0,0x7
    80001d90:	28c50513          	addi	a0,a0,652 # 80009018 <ticks>
    80001d94:	411c                	lw	a5,0(a0)
    80001d96:	2785                	addiw	a5,a5,1
    80001d98:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	a7a080e7          	jalr	-1414(ra) # 80001814 <wakeup>
  release(&tickslock);
    80001da2:	8526                	mv	a0,s1
    80001da4:	00004097          	auipc	ra,0x4
    80001da8:	5c2080e7          	jalr	1474(ra) # 80006366 <release>
}
    80001dac:	60e2                	ld	ra,24(sp)
    80001dae:	6442                	ld	s0,16(sp)
    80001db0:	64a2                	ld	s1,8(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret

0000000080001db6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	e426                	sd	s1,8(sp)
    80001dbe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dc0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001dc4:	00074d63          	bltz	a4,80001dde <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001dc8:	57fd                	li	a5,-1
    80001dca:	17fe                	slli	a5,a5,0x3f
    80001dcc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001dce:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001dd0:	06f70363          	beq	a4,a5,80001e36 <devintr+0x80>
  }
}
    80001dd4:	60e2                	ld	ra,24(sp)
    80001dd6:	6442                	ld	s0,16(sp)
    80001dd8:	64a2                	ld	s1,8(sp)
    80001dda:	6105                	addi	sp,sp,32
    80001ddc:	8082                	ret
     (scause & 0xff) == 9){
    80001dde:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001de2:	46a5                	li	a3,9
    80001de4:	fed792e3          	bne	a5,a3,80001dc8 <devintr+0x12>
    int irq = plic_claim();
    80001de8:	00003097          	auipc	ra,0x3
    80001dec:	490080e7          	jalr	1168(ra) # 80005278 <plic_claim>
    80001df0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001df2:	47a9                	li	a5,10
    80001df4:	02f50763          	beq	a0,a5,80001e22 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001df8:	4785                	li	a5,1
    80001dfa:	02f50963          	beq	a0,a5,80001e2c <devintr+0x76>
    return 1;
    80001dfe:	4505                	li	a0,1
    } else if(irq){
    80001e00:	d8f1                	beqz	s1,80001dd4 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001e02:	85a6                	mv	a1,s1
    80001e04:	00006517          	auipc	a0,0x6
    80001e08:	4cc50513          	addi	a0,a0,1228 # 800082d0 <states.1718+0x60>
    80001e0c:	00004097          	auipc	ra,0x4
    80001e10:	fa6080e7          	jalr	-90(ra) # 80005db2 <printf>
      plic_complete(irq);
    80001e14:	8526                	mv	a0,s1
    80001e16:	00003097          	auipc	ra,0x3
    80001e1a:	486080e7          	jalr	1158(ra) # 8000529c <plic_complete>
    return 1;
    80001e1e:	4505                	li	a0,1
    80001e20:	bf55                	j	80001dd4 <devintr+0x1e>
      uartintr();
    80001e22:	00004097          	auipc	ra,0x4
    80001e26:	3b0080e7          	jalr	944(ra) # 800061d2 <uartintr>
    80001e2a:	b7ed                	j	80001e14 <devintr+0x5e>
      virtio_disk_intr();
    80001e2c:	00004097          	auipc	ra,0x4
    80001e30:	950080e7          	jalr	-1712(ra) # 8000577c <virtio_disk_intr>
    80001e34:	b7c5                	j	80001e14 <devintr+0x5e>
    if(cpuid() == 0){
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	16a080e7          	jalr	362(ra) # 80000fa0 <cpuid>
    80001e3e:	c901                	beqz	a0,80001e4e <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001e40:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001e44:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001e46:	14479073          	csrw	sip,a5
    return 2;
    80001e4a:	4509                	li	a0,2
    80001e4c:	b761                	j	80001dd4 <devintr+0x1e>
      clockintr();
    80001e4e:	00000097          	auipc	ra,0x0
    80001e52:	f22080e7          	jalr	-222(ra) # 80001d70 <clockintr>
    80001e56:	b7ed                	j	80001e40 <devintr+0x8a>

0000000080001e58 <usertrap>:
{
    80001e58:	1101                	addi	sp,sp,-32
    80001e5a:	ec06                	sd	ra,24(sp)
    80001e5c:	e822                	sd	s0,16(sp)
    80001e5e:	e426                	sd	s1,8(sp)
    80001e60:	e04a                	sd	s2,0(sp)
    80001e62:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e64:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001e68:	1007f793          	andi	a5,a5,256
    80001e6c:	e3b9                	bnez	a5,80001eb2 <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001e6e:	00003797          	auipc	a5,0x3
    80001e72:	30278793          	addi	a5,a5,770 # 80005170 <kernelvec>
    80001e76:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	152080e7          	jalr	338(ra) # 80000fcc <myproc>
    80001e82:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001e84:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e86:	14102773          	csrr	a4,sepc
    80001e8a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e8c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001e90:	47a1                	li	a5,8
    80001e92:	02f70863          	beq	a4,a5,80001ec2 <usertrap+0x6a>
    80001e96:	14202773          	csrr	a4,scause
  else if( r_scause() == 15)
    80001e9a:	47bd                	li	a5,15
    80001e9c:	06f70563          	beq	a4,a5,80001f06 <usertrap+0xae>
  else if((which_dev = devintr()) != 0){
    80001ea0:	00000097          	auipc	ra,0x0
    80001ea4:	f16080e7          	jalr	-234(ra) # 80001db6 <devintr>
    80001ea8:	892a                	mv	s2,a0
    80001eaa:	c935                	beqz	a0,80001f1e <usertrap+0xc6>
  if(p->killed)
    80001eac:	549c                	lw	a5,40(s1)
    80001eae:	c7dd                	beqz	a5,80001f5c <usertrap+0x104>
    80001eb0:	a04d                	j	80001f52 <usertrap+0xfa>
    panic("usertrap: not from user mode");
    80001eb2:	00006517          	auipc	a0,0x6
    80001eb6:	43e50513          	addi	a0,a0,1086 # 800082f0 <states.1718+0x80>
    80001eba:	00004097          	auipc	ra,0x4
    80001ebe:	eae080e7          	jalr	-338(ra) # 80005d68 <panic>
    if(p->killed)
    80001ec2:	551c                	lw	a5,40(a0)
    80001ec4:	eb9d                	bnez	a5,80001efa <usertrap+0xa2>
    p->trapframe->epc += 4;
    80001ec6:	6cb8                	ld	a4,88(s1)
    80001ec8:	6f1c                	ld	a5,24(a4)
    80001eca:	0791                	addi	a5,a5,4
    80001ecc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ece:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ed2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ed6:	10079073          	csrw	sstatus,a5
    syscall();
    80001eda:	00000097          	auipc	ra,0x0
    80001ede:	2d8080e7          	jalr	728(ra) # 800021b2 <syscall>
  if(p->killed)
    80001ee2:	549c                	lw	a5,40(s1)
    80001ee4:	e7c1                	bnez	a5,80001f6c <usertrap+0x114>
  usertrapret();
    80001ee6:	00000097          	auipc	ra,0x0
    80001eea:	dec080e7          	jalr	-532(ra) # 80001cd2 <usertrapret>
}
    80001eee:	60e2                	ld	ra,24(sp)
    80001ef0:	6442                	ld	s0,16(sp)
    80001ef2:	64a2                	ld	s1,8(sp)
    80001ef4:	6902                	ld	s2,0(sp)
    80001ef6:	6105                	addi	sp,sp,32
    80001ef8:	8082                	ret
      exit(-1);
    80001efa:	557d                	li	a0,-1
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	9e8080e7          	jalr	-1560(ra) # 800018e4 <exit>
    80001f04:	b7c9                	j	80001ec6 <usertrap+0x6e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f06:	143025f3          	csrr	a1,stval
    int result = CowFoldHandler( p->pagetable, r_stval());
    80001f0a:	6928                	ld	a0,80(a0)
    80001f0c:	00000097          	auipc	ra,0x0
    80001f10:	d24080e7          	jalr	-732(ra) # 80001c30 <CowFoldHandler>
    if(result <0)
    80001f14:	fc0557e3          	bgez	a0,80001ee2 <usertrap+0x8a>
      p->killed = 1;
    80001f18:	4785                	li	a5,1
    80001f1a:	d49c                	sw	a5,40(s1)
    80001f1c:	a815                	j	80001f50 <usertrap+0xf8>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f1e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001f22:	5890                	lw	a2,48(s1)
    80001f24:	00006517          	auipc	a0,0x6
    80001f28:	3ec50513          	addi	a0,a0,1004 # 80008310 <states.1718+0xa0>
    80001f2c:	00004097          	auipc	ra,0x4
    80001f30:	e86080e7          	jalr	-378(ra) # 80005db2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f34:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f38:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001f3c:	00006517          	auipc	a0,0x6
    80001f40:	40450513          	addi	a0,a0,1028 # 80008340 <states.1718+0xd0>
    80001f44:	00004097          	auipc	ra,0x4
    80001f48:	e6e080e7          	jalr	-402(ra) # 80005db2 <printf>
    p->killed = 1;
    80001f4c:	4785                	li	a5,1
    80001f4e:	d49c                	sw	a5,40(s1)
{
    80001f50:	4901                	li	s2,0
    exit(-1);
    80001f52:	557d                	li	a0,-1
    80001f54:	00000097          	auipc	ra,0x0
    80001f58:	990080e7          	jalr	-1648(ra) # 800018e4 <exit>
  if(which_dev == 2)
    80001f5c:	4789                	li	a5,2
    80001f5e:	f8f914e3          	bne	s2,a5,80001ee6 <usertrap+0x8e>
    yield();
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	6ea080e7          	jalr	1770(ra) # 8000164c <yield>
    80001f6a:	bfb5                	j	80001ee6 <usertrap+0x8e>
  if(p->killed)
    80001f6c:	4901                	li	s2,0
    80001f6e:	b7d5                	j	80001f52 <usertrap+0xfa>

0000000080001f70 <kerneltrap>:
{
    80001f70:	7179                	addi	sp,sp,-48
    80001f72:	f406                	sd	ra,40(sp)
    80001f74:	f022                	sd	s0,32(sp)
    80001f76:	ec26                	sd	s1,24(sp)
    80001f78:	e84a                	sd	s2,16(sp)
    80001f7a:	e44e                	sd	s3,8(sp)
    80001f7c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f7e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f82:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f86:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001f8a:	1004f793          	andi	a5,s1,256
    80001f8e:	cb85                	beqz	a5,80001fbe <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f90:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f94:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001f96:	ef85                	bnez	a5,80001fce <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001f98:	00000097          	auipc	ra,0x0
    80001f9c:	e1e080e7          	jalr	-482(ra) # 80001db6 <devintr>
    80001fa0:	cd1d                	beqz	a0,80001fde <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001fa2:	4789                	li	a5,2
    80001fa4:	06f50a63          	beq	a0,a5,80002018 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001fa8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fac:	10049073          	csrw	sstatus,s1
}
    80001fb0:	70a2                	ld	ra,40(sp)
    80001fb2:	7402                	ld	s0,32(sp)
    80001fb4:	64e2                	ld	s1,24(sp)
    80001fb6:	6942                	ld	s2,16(sp)
    80001fb8:	69a2                	ld	s3,8(sp)
    80001fba:	6145                	addi	sp,sp,48
    80001fbc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001fbe:	00006517          	auipc	a0,0x6
    80001fc2:	3a250513          	addi	a0,a0,930 # 80008360 <states.1718+0xf0>
    80001fc6:	00004097          	auipc	ra,0x4
    80001fca:	da2080e7          	jalr	-606(ra) # 80005d68 <panic>
    panic("kerneltrap: interrupts enabled");
    80001fce:	00006517          	auipc	a0,0x6
    80001fd2:	3ba50513          	addi	a0,a0,954 # 80008388 <states.1718+0x118>
    80001fd6:	00004097          	auipc	ra,0x4
    80001fda:	d92080e7          	jalr	-622(ra) # 80005d68 <panic>
    printf("scause %p\n", scause);
    80001fde:	85ce                	mv	a1,s3
    80001fe0:	00006517          	auipc	a0,0x6
    80001fe4:	3c850513          	addi	a0,a0,968 # 800083a8 <states.1718+0x138>
    80001fe8:	00004097          	auipc	ra,0x4
    80001fec:	dca080e7          	jalr	-566(ra) # 80005db2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ff0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001ff4:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	3c050513          	addi	a0,a0,960 # 800083b8 <states.1718+0x148>
    80002000:	00004097          	auipc	ra,0x4
    80002004:	db2080e7          	jalr	-590(ra) # 80005db2 <printf>
    panic("kerneltrap");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	3c850513          	addi	a0,a0,968 # 800083d0 <states.1718+0x160>
    80002010:	00004097          	auipc	ra,0x4
    80002014:	d58080e7          	jalr	-680(ra) # 80005d68 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	fb4080e7          	jalr	-76(ra) # 80000fcc <myproc>
    80002020:	d541                	beqz	a0,80001fa8 <kerneltrap+0x38>
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	faa080e7          	jalr	-86(ra) # 80000fcc <myproc>
    8000202a:	4d18                	lw	a4,24(a0)
    8000202c:	4791                	li	a5,4
    8000202e:	f6f71de3          	bne	a4,a5,80001fa8 <kerneltrap+0x38>
    yield();
    80002032:	fffff097          	auipc	ra,0xfffff
    80002036:	61a080e7          	jalr	1562(ra) # 8000164c <yield>
    8000203a:	b7bd                	j	80001fa8 <kerneltrap+0x38>

000000008000203c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000203c:	1101                	addi	sp,sp,-32
    8000203e:	ec06                	sd	ra,24(sp)
    80002040:	e822                	sd	s0,16(sp)
    80002042:	e426                	sd	s1,8(sp)
    80002044:	1000                	addi	s0,sp,32
    80002046:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002048:	fffff097          	auipc	ra,0xfffff
    8000204c:	f84080e7          	jalr	-124(ra) # 80000fcc <myproc>
  switch (n) {
    80002050:	4795                	li	a5,5
    80002052:	0497e163          	bltu	a5,s1,80002094 <argraw+0x58>
    80002056:	048a                	slli	s1,s1,0x2
    80002058:	00006717          	auipc	a4,0x6
    8000205c:	3b070713          	addi	a4,a4,944 # 80008408 <states.1718+0x198>
    80002060:	94ba                	add	s1,s1,a4
    80002062:	409c                	lw	a5,0(s1)
    80002064:	97ba                	add	a5,a5,a4
    80002066:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002068:	6d3c                	ld	a5,88(a0)
    8000206a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000206c:	60e2                	ld	ra,24(sp)
    8000206e:	6442                	ld	s0,16(sp)
    80002070:	64a2                	ld	s1,8(sp)
    80002072:	6105                	addi	sp,sp,32
    80002074:	8082                	ret
    return p->trapframe->a1;
    80002076:	6d3c                	ld	a5,88(a0)
    80002078:	7fa8                	ld	a0,120(a5)
    8000207a:	bfcd                	j	8000206c <argraw+0x30>
    return p->trapframe->a2;
    8000207c:	6d3c                	ld	a5,88(a0)
    8000207e:	63c8                	ld	a0,128(a5)
    80002080:	b7f5                	j	8000206c <argraw+0x30>
    return p->trapframe->a3;
    80002082:	6d3c                	ld	a5,88(a0)
    80002084:	67c8                	ld	a0,136(a5)
    80002086:	b7dd                	j	8000206c <argraw+0x30>
    return p->trapframe->a4;
    80002088:	6d3c                	ld	a5,88(a0)
    8000208a:	6bc8                	ld	a0,144(a5)
    8000208c:	b7c5                	j	8000206c <argraw+0x30>
    return p->trapframe->a5;
    8000208e:	6d3c                	ld	a5,88(a0)
    80002090:	6fc8                	ld	a0,152(a5)
    80002092:	bfe9                	j	8000206c <argraw+0x30>
  panic("argraw");
    80002094:	00006517          	auipc	a0,0x6
    80002098:	34c50513          	addi	a0,a0,844 # 800083e0 <states.1718+0x170>
    8000209c:	00004097          	auipc	ra,0x4
    800020a0:	ccc080e7          	jalr	-820(ra) # 80005d68 <panic>

00000000800020a4 <fetchaddr>:
{
    800020a4:	1101                	addi	sp,sp,-32
    800020a6:	ec06                	sd	ra,24(sp)
    800020a8:	e822                	sd	s0,16(sp)
    800020aa:	e426                	sd	s1,8(sp)
    800020ac:	e04a                	sd	s2,0(sp)
    800020ae:	1000                	addi	s0,sp,32
    800020b0:	84aa                	mv	s1,a0
    800020b2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	f18080e7          	jalr	-232(ra) # 80000fcc <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800020bc:	653c                	ld	a5,72(a0)
    800020be:	02f4f863          	bgeu	s1,a5,800020ee <fetchaddr+0x4a>
    800020c2:	00848713          	addi	a4,s1,8
    800020c6:	02e7e663          	bltu	a5,a4,800020f2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800020ca:	46a1                	li	a3,8
    800020cc:	8626                	mv	a2,s1
    800020ce:	85ca                	mv	a1,s2
    800020d0:	6928                	ld	a0,80(a0)
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	c48080e7          	jalr	-952(ra) # 80000d1a <copyin>
    800020da:	00a03533          	snez	a0,a0
    800020de:	40a00533          	neg	a0,a0
}
    800020e2:	60e2                	ld	ra,24(sp)
    800020e4:	6442                	ld	s0,16(sp)
    800020e6:	64a2                	ld	s1,8(sp)
    800020e8:	6902                	ld	s2,0(sp)
    800020ea:	6105                	addi	sp,sp,32
    800020ec:	8082                	ret
    return -1;
    800020ee:	557d                	li	a0,-1
    800020f0:	bfcd                	j	800020e2 <fetchaddr+0x3e>
    800020f2:	557d                	li	a0,-1
    800020f4:	b7fd                	j	800020e2 <fetchaddr+0x3e>

00000000800020f6 <fetchstr>:
{
    800020f6:	7179                	addi	sp,sp,-48
    800020f8:	f406                	sd	ra,40(sp)
    800020fa:	f022                	sd	s0,32(sp)
    800020fc:	ec26                	sd	s1,24(sp)
    800020fe:	e84a                	sd	s2,16(sp)
    80002100:	e44e                	sd	s3,8(sp)
    80002102:	1800                	addi	s0,sp,48
    80002104:	892a                	mv	s2,a0
    80002106:	84ae                	mv	s1,a1
    80002108:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	ec2080e7          	jalr	-318(ra) # 80000fcc <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002112:	86ce                	mv	a3,s3
    80002114:	864a                	mv	a2,s2
    80002116:	85a6                	mv	a1,s1
    80002118:	6928                	ld	a0,80(a0)
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	c8c080e7          	jalr	-884(ra) # 80000da6 <copyinstr>
  if(err < 0)
    80002122:	00054763          	bltz	a0,80002130 <fetchstr+0x3a>
  return strlen(buf);
    80002126:	8526                	mv	a0,s1
    80002128:	ffffe097          	auipc	ra,0xffffe
    8000212c:	310080e7          	jalr	784(ra) # 80000438 <strlen>
}
    80002130:	70a2                	ld	ra,40(sp)
    80002132:	7402                	ld	s0,32(sp)
    80002134:	64e2                	ld	s1,24(sp)
    80002136:	6942                	ld	s2,16(sp)
    80002138:	69a2                	ld	s3,8(sp)
    8000213a:	6145                	addi	sp,sp,48
    8000213c:	8082                	ret

000000008000213e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    8000213e:	1101                	addi	sp,sp,-32
    80002140:	ec06                	sd	ra,24(sp)
    80002142:	e822                	sd	s0,16(sp)
    80002144:	e426                	sd	s1,8(sp)
    80002146:	1000                	addi	s0,sp,32
    80002148:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000214a:	00000097          	auipc	ra,0x0
    8000214e:	ef2080e7          	jalr	-270(ra) # 8000203c <argraw>
    80002152:	c088                	sw	a0,0(s1)
  return 0;
}
    80002154:	4501                	li	a0,0
    80002156:	60e2                	ld	ra,24(sp)
    80002158:	6442                	ld	s0,16(sp)
    8000215a:	64a2                	ld	s1,8(sp)
    8000215c:	6105                	addi	sp,sp,32
    8000215e:	8082                	ret

0000000080002160 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002160:	1101                	addi	sp,sp,-32
    80002162:	ec06                	sd	ra,24(sp)
    80002164:	e822                	sd	s0,16(sp)
    80002166:	e426                	sd	s1,8(sp)
    80002168:	1000                	addi	s0,sp,32
    8000216a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000216c:	00000097          	auipc	ra,0x0
    80002170:	ed0080e7          	jalr	-304(ra) # 8000203c <argraw>
    80002174:	e088                	sd	a0,0(s1)
  return 0;
}
    80002176:	4501                	li	a0,0
    80002178:	60e2                	ld	ra,24(sp)
    8000217a:	6442                	ld	s0,16(sp)
    8000217c:	64a2                	ld	s1,8(sp)
    8000217e:	6105                	addi	sp,sp,32
    80002180:	8082                	ret

0000000080002182 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002182:	1101                	addi	sp,sp,-32
    80002184:	ec06                	sd	ra,24(sp)
    80002186:	e822                	sd	s0,16(sp)
    80002188:	e426                	sd	s1,8(sp)
    8000218a:	e04a                	sd	s2,0(sp)
    8000218c:	1000                	addi	s0,sp,32
    8000218e:	84ae                	mv	s1,a1
    80002190:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002192:	00000097          	auipc	ra,0x0
    80002196:	eaa080e7          	jalr	-342(ra) # 8000203c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000219a:	864a                	mv	a2,s2
    8000219c:	85a6                	mv	a1,s1
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	f58080e7          	jalr	-168(ra) # 800020f6 <fetchstr>
}
    800021a6:	60e2                	ld	ra,24(sp)
    800021a8:	6442                	ld	s0,16(sp)
    800021aa:	64a2                	ld	s1,8(sp)
    800021ac:	6902                	ld	s2,0(sp)
    800021ae:	6105                	addi	sp,sp,32
    800021b0:	8082                	ret

00000000800021b2 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    800021b2:	1101                	addi	sp,sp,-32
    800021b4:	ec06                	sd	ra,24(sp)
    800021b6:	e822                	sd	s0,16(sp)
    800021b8:	e426                	sd	s1,8(sp)
    800021ba:	e04a                	sd	s2,0(sp)
    800021bc:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	e0e080e7          	jalr	-498(ra) # 80000fcc <myproc>
    800021c6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800021c8:	05853903          	ld	s2,88(a0)
    800021cc:	0a893783          	ld	a5,168(s2)
    800021d0:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800021d4:	37fd                	addiw	a5,a5,-1
    800021d6:	4751                	li	a4,20
    800021d8:	00f76f63          	bltu	a4,a5,800021f6 <syscall+0x44>
    800021dc:	00369713          	slli	a4,a3,0x3
    800021e0:	00006797          	auipc	a5,0x6
    800021e4:	24078793          	addi	a5,a5,576 # 80008420 <syscalls>
    800021e8:	97ba                	add	a5,a5,a4
    800021ea:	639c                	ld	a5,0(a5)
    800021ec:	c789                	beqz	a5,800021f6 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800021ee:	9782                	jalr	a5
    800021f0:	06a93823          	sd	a0,112(s2)
    800021f4:	a839                	j	80002212 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800021f6:	15848613          	addi	a2,s1,344
    800021fa:	588c                	lw	a1,48(s1)
    800021fc:	00006517          	auipc	a0,0x6
    80002200:	1ec50513          	addi	a0,a0,492 # 800083e8 <states.1718+0x178>
    80002204:	00004097          	auipc	ra,0x4
    80002208:	bae080e7          	jalr	-1106(ra) # 80005db2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000220c:	6cbc                	ld	a5,88(s1)
    8000220e:	577d                	li	a4,-1
    80002210:	fbb8                	sd	a4,112(a5)
  }
}
    80002212:	60e2                	ld	ra,24(sp)
    80002214:	6442                	ld	s0,16(sp)
    80002216:	64a2                	ld	s1,8(sp)
    80002218:	6902                	ld	s2,0(sp)
    8000221a:	6105                	addi	sp,sp,32
    8000221c:	8082                	ret

000000008000221e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000221e:	1101                	addi	sp,sp,-32
    80002220:	ec06                	sd	ra,24(sp)
    80002222:	e822                	sd	s0,16(sp)
    80002224:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002226:	fec40593          	addi	a1,s0,-20
    8000222a:	4501                	li	a0,0
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	f12080e7          	jalr	-238(ra) # 8000213e <argint>
    return -1;
    80002234:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002236:	00054963          	bltz	a0,80002248 <sys_exit+0x2a>
  exit(n);
    8000223a:	fec42503          	lw	a0,-20(s0)
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	6a6080e7          	jalr	1702(ra) # 800018e4 <exit>
  return 0;  // not reached
    80002246:	4781                	li	a5,0
}
    80002248:	853e                	mv	a0,a5
    8000224a:	60e2                	ld	ra,24(sp)
    8000224c:	6442                	ld	s0,16(sp)
    8000224e:	6105                	addi	sp,sp,32
    80002250:	8082                	ret

0000000080002252 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002252:	1141                	addi	sp,sp,-16
    80002254:	e406                	sd	ra,8(sp)
    80002256:	e022                	sd	s0,0(sp)
    80002258:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	d72080e7          	jalr	-654(ra) # 80000fcc <myproc>
}
    80002262:	5908                	lw	a0,48(a0)
    80002264:	60a2                	ld	ra,8(sp)
    80002266:	6402                	ld	s0,0(sp)
    80002268:	0141                	addi	sp,sp,16
    8000226a:	8082                	ret

000000008000226c <sys_fork>:

uint64
sys_fork(void)
{
    8000226c:	1141                	addi	sp,sp,-16
    8000226e:	e406                	sd	ra,8(sp)
    80002270:	e022                	sd	s0,0(sp)
    80002272:	0800                	addi	s0,sp,16
  return fork();
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	126080e7          	jalr	294(ra) # 8000139a <fork>
}
    8000227c:	60a2                	ld	ra,8(sp)
    8000227e:	6402                	ld	s0,0(sp)
    80002280:	0141                	addi	sp,sp,16
    80002282:	8082                	ret

0000000080002284 <sys_wait>:

uint64
sys_wait(void)
{
    80002284:	1101                	addi	sp,sp,-32
    80002286:	ec06                	sd	ra,24(sp)
    80002288:	e822                	sd	s0,16(sp)
    8000228a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000228c:	fe840593          	addi	a1,s0,-24
    80002290:	4501                	li	a0,0
    80002292:	00000097          	auipc	ra,0x0
    80002296:	ece080e7          	jalr	-306(ra) # 80002160 <argaddr>
    8000229a:	87aa                	mv	a5,a0
    return -1;
    8000229c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    8000229e:	0007c863          	bltz	a5,800022ae <sys_wait+0x2a>
  return wait(p);
    800022a2:	fe843503          	ld	a0,-24(s0)
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	446080e7          	jalr	1094(ra) # 800016ec <wait>
}
    800022ae:	60e2                	ld	ra,24(sp)
    800022b0:	6442                	ld	s0,16(sp)
    800022b2:	6105                	addi	sp,sp,32
    800022b4:	8082                	ret

00000000800022b6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800022b6:	7179                	addi	sp,sp,-48
    800022b8:	f406                	sd	ra,40(sp)
    800022ba:	f022                	sd	s0,32(sp)
    800022bc:	ec26                	sd	s1,24(sp)
    800022be:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800022c0:	fdc40593          	addi	a1,s0,-36
    800022c4:	4501                	li	a0,0
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	e78080e7          	jalr	-392(ra) # 8000213e <argint>
    800022ce:	87aa                	mv	a5,a0
    return -1;
    800022d0:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    800022d2:	0207c063          	bltz	a5,800022f2 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	cf6080e7          	jalr	-778(ra) # 80000fcc <myproc>
    800022de:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800022e0:	fdc42503          	lw	a0,-36(s0)
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	042080e7          	jalr	66(ra) # 80001326 <growproc>
    800022ec:	00054863          	bltz	a0,800022fc <sys_sbrk+0x46>
    return -1;
  return addr;
    800022f0:	8526                	mv	a0,s1
}
    800022f2:	70a2                	ld	ra,40(sp)
    800022f4:	7402                	ld	s0,32(sp)
    800022f6:	64e2                	ld	s1,24(sp)
    800022f8:	6145                	addi	sp,sp,48
    800022fa:	8082                	ret
    return -1;
    800022fc:	557d                	li	a0,-1
    800022fe:	bfd5                	j	800022f2 <sys_sbrk+0x3c>

0000000080002300 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002300:	7139                	addi	sp,sp,-64
    80002302:	fc06                	sd	ra,56(sp)
    80002304:	f822                	sd	s0,48(sp)
    80002306:	f426                	sd	s1,40(sp)
    80002308:	f04a                	sd	s2,32(sp)
    8000230a:	ec4e                	sd	s3,24(sp)
    8000230c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    8000230e:	fcc40593          	addi	a1,s0,-52
    80002312:	4501                	li	a0,0
    80002314:	00000097          	auipc	ra,0x0
    80002318:	e2a080e7          	jalr	-470(ra) # 8000213e <argint>
    return -1;
    8000231c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000231e:	06054563          	bltz	a0,80002388 <sys_sleep+0x88>
  acquire(&tickslock);
    80002322:	0022d517          	auipc	a0,0x22d
    80002326:	b7650513          	addi	a0,a0,-1162 # 8022ee98 <tickslock>
    8000232a:	00004097          	auipc	ra,0x4
    8000232e:	f88080e7          	jalr	-120(ra) # 800062b2 <acquire>
  ticks0 = ticks;
    80002332:	00007917          	auipc	s2,0x7
    80002336:	ce692903          	lw	s2,-794(s2) # 80009018 <ticks>
  while(ticks - ticks0 < n){
    8000233a:	fcc42783          	lw	a5,-52(s0)
    8000233e:	cf85                	beqz	a5,80002376 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002340:	0022d997          	auipc	s3,0x22d
    80002344:	b5898993          	addi	s3,s3,-1192 # 8022ee98 <tickslock>
    80002348:	00007497          	auipc	s1,0x7
    8000234c:	cd048493          	addi	s1,s1,-816 # 80009018 <ticks>
    if(myproc()->killed){
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	c7c080e7          	jalr	-900(ra) # 80000fcc <myproc>
    80002358:	551c                	lw	a5,40(a0)
    8000235a:	ef9d                	bnez	a5,80002398 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000235c:	85ce                	mv	a1,s3
    8000235e:	8526                	mv	a0,s1
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	328080e7          	jalr	808(ra) # 80001688 <sleep>
  while(ticks - ticks0 < n){
    80002368:	409c                	lw	a5,0(s1)
    8000236a:	412787bb          	subw	a5,a5,s2
    8000236e:	fcc42703          	lw	a4,-52(s0)
    80002372:	fce7efe3          	bltu	a5,a4,80002350 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002376:	0022d517          	auipc	a0,0x22d
    8000237a:	b2250513          	addi	a0,a0,-1246 # 8022ee98 <tickslock>
    8000237e:	00004097          	auipc	ra,0x4
    80002382:	fe8080e7          	jalr	-24(ra) # 80006366 <release>
  return 0;
    80002386:	4781                	li	a5,0
}
    80002388:	853e                	mv	a0,a5
    8000238a:	70e2                	ld	ra,56(sp)
    8000238c:	7442                	ld	s0,48(sp)
    8000238e:	74a2                	ld	s1,40(sp)
    80002390:	7902                	ld	s2,32(sp)
    80002392:	69e2                	ld	s3,24(sp)
    80002394:	6121                	addi	sp,sp,64
    80002396:	8082                	ret
      release(&tickslock);
    80002398:	0022d517          	auipc	a0,0x22d
    8000239c:	b0050513          	addi	a0,a0,-1280 # 8022ee98 <tickslock>
    800023a0:	00004097          	auipc	ra,0x4
    800023a4:	fc6080e7          	jalr	-58(ra) # 80006366 <release>
      return -1;
    800023a8:	57fd                	li	a5,-1
    800023aa:	bff9                	j	80002388 <sys_sleep+0x88>

00000000800023ac <sys_kill>:

uint64
sys_kill(void)
{
    800023ac:	1101                	addi	sp,sp,-32
    800023ae:	ec06                	sd	ra,24(sp)
    800023b0:	e822                	sd	s0,16(sp)
    800023b2:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800023b4:	fec40593          	addi	a1,s0,-20
    800023b8:	4501                	li	a0,0
    800023ba:	00000097          	auipc	ra,0x0
    800023be:	d84080e7          	jalr	-636(ra) # 8000213e <argint>
    800023c2:	87aa                	mv	a5,a0
    return -1;
    800023c4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800023c6:	0007c863          	bltz	a5,800023d6 <sys_kill+0x2a>
  return kill(pid);
    800023ca:	fec42503          	lw	a0,-20(s0)
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	5ec080e7          	jalr	1516(ra) # 800019ba <kill>
}
    800023d6:	60e2                	ld	ra,24(sp)
    800023d8:	6442                	ld	s0,16(sp)
    800023da:	6105                	addi	sp,sp,32
    800023dc:	8082                	ret

00000000800023de <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800023de:	1101                	addi	sp,sp,-32
    800023e0:	ec06                	sd	ra,24(sp)
    800023e2:	e822                	sd	s0,16(sp)
    800023e4:	e426                	sd	s1,8(sp)
    800023e6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800023e8:	0022d517          	auipc	a0,0x22d
    800023ec:	ab050513          	addi	a0,a0,-1360 # 8022ee98 <tickslock>
    800023f0:	00004097          	auipc	ra,0x4
    800023f4:	ec2080e7          	jalr	-318(ra) # 800062b2 <acquire>
  xticks = ticks;
    800023f8:	00007497          	auipc	s1,0x7
    800023fc:	c204a483          	lw	s1,-992(s1) # 80009018 <ticks>
  release(&tickslock);
    80002400:	0022d517          	auipc	a0,0x22d
    80002404:	a9850513          	addi	a0,a0,-1384 # 8022ee98 <tickslock>
    80002408:	00004097          	auipc	ra,0x4
    8000240c:	f5e080e7          	jalr	-162(ra) # 80006366 <release>
  return xticks;
}
    80002410:	02049513          	slli	a0,s1,0x20
    80002414:	9101                	srli	a0,a0,0x20
    80002416:	60e2                	ld	ra,24(sp)
    80002418:	6442                	ld	s0,16(sp)
    8000241a:	64a2                	ld	s1,8(sp)
    8000241c:	6105                	addi	sp,sp,32
    8000241e:	8082                	ret

0000000080002420 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002420:	7179                	addi	sp,sp,-48
    80002422:	f406                	sd	ra,40(sp)
    80002424:	f022                	sd	s0,32(sp)
    80002426:	ec26                	sd	s1,24(sp)
    80002428:	e84a                	sd	s2,16(sp)
    8000242a:	e44e                	sd	s3,8(sp)
    8000242c:	e052                	sd	s4,0(sp)
    8000242e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002430:	00006597          	auipc	a1,0x6
    80002434:	0a058593          	addi	a1,a1,160 # 800084d0 <syscalls+0xb0>
    80002438:	0022d517          	auipc	a0,0x22d
    8000243c:	a7850513          	addi	a0,a0,-1416 # 8022eeb0 <bcache>
    80002440:	00004097          	auipc	ra,0x4
    80002444:	de2080e7          	jalr	-542(ra) # 80006222 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002448:	00235797          	auipc	a5,0x235
    8000244c:	a6878793          	addi	a5,a5,-1432 # 80236eb0 <bcache+0x8000>
    80002450:	00235717          	auipc	a4,0x235
    80002454:	cc870713          	addi	a4,a4,-824 # 80237118 <bcache+0x8268>
    80002458:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000245c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002460:	0022d497          	auipc	s1,0x22d
    80002464:	a6848493          	addi	s1,s1,-1432 # 8022eec8 <bcache+0x18>
    b->next = bcache.head.next;
    80002468:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000246a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000246c:	00006a17          	auipc	s4,0x6
    80002470:	06ca0a13          	addi	s4,s4,108 # 800084d8 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002474:	2b893783          	ld	a5,696(s2)
    80002478:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000247a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000247e:	85d2                	mv	a1,s4
    80002480:	01048513          	addi	a0,s1,16
    80002484:	00001097          	auipc	ra,0x1
    80002488:	4bc080e7          	jalr	1212(ra) # 80003940 <initsleeplock>
    bcache.head.next->prev = b;
    8000248c:	2b893783          	ld	a5,696(s2)
    80002490:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002492:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002496:	45848493          	addi	s1,s1,1112
    8000249a:	fd349de3          	bne	s1,s3,80002474 <binit+0x54>
  }
}
    8000249e:	70a2                	ld	ra,40(sp)
    800024a0:	7402                	ld	s0,32(sp)
    800024a2:	64e2                	ld	s1,24(sp)
    800024a4:	6942                	ld	s2,16(sp)
    800024a6:	69a2                	ld	s3,8(sp)
    800024a8:	6a02                	ld	s4,0(sp)
    800024aa:	6145                	addi	sp,sp,48
    800024ac:	8082                	ret

00000000800024ae <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800024ae:	7179                	addi	sp,sp,-48
    800024b0:	f406                	sd	ra,40(sp)
    800024b2:	f022                	sd	s0,32(sp)
    800024b4:	ec26                	sd	s1,24(sp)
    800024b6:	e84a                	sd	s2,16(sp)
    800024b8:	e44e                	sd	s3,8(sp)
    800024ba:	1800                	addi	s0,sp,48
    800024bc:	89aa                	mv	s3,a0
    800024be:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800024c0:	0022d517          	auipc	a0,0x22d
    800024c4:	9f050513          	addi	a0,a0,-1552 # 8022eeb0 <bcache>
    800024c8:	00004097          	auipc	ra,0x4
    800024cc:	dea080e7          	jalr	-534(ra) # 800062b2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800024d0:	00235497          	auipc	s1,0x235
    800024d4:	c984b483          	ld	s1,-872(s1) # 80237168 <bcache+0x82b8>
    800024d8:	00235797          	auipc	a5,0x235
    800024dc:	c4078793          	addi	a5,a5,-960 # 80237118 <bcache+0x8268>
    800024e0:	02f48f63          	beq	s1,a5,8000251e <bread+0x70>
    800024e4:	873e                	mv	a4,a5
    800024e6:	a021                	j	800024ee <bread+0x40>
    800024e8:	68a4                	ld	s1,80(s1)
    800024ea:	02e48a63          	beq	s1,a4,8000251e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800024ee:	449c                	lw	a5,8(s1)
    800024f0:	ff379ce3          	bne	a5,s3,800024e8 <bread+0x3a>
    800024f4:	44dc                	lw	a5,12(s1)
    800024f6:	ff2799e3          	bne	a5,s2,800024e8 <bread+0x3a>
      b->refcnt++;
    800024fa:	40bc                	lw	a5,64(s1)
    800024fc:	2785                	addiw	a5,a5,1
    800024fe:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002500:	0022d517          	auipc	a0,0x22d
    80002504:	9b050513          	addi	a0,a0,-1616 # 8022eeb0 <bcache>
    80002508:	00004097          	auipc	ra,0x4
    8000250c:	e5e080e7          	jalr	-418(ra) # 80006366 <release>
      acquiresleep(&b->lock);
    80002510:	01048513          	addi	a0,s1,16
    80002514:	00001097          	auipc	ra,0x1
    80002518:	466080e7          	jalr	1126(ra) # 8000397a <acquiresleep>
      return b;
    8000251c:	a8b9                	j	8000257a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000251e:	00235497          	auipc	s1,0x235
    80002522:	c424b483          	ld	s1,-958(s1) # 80237160 <bcache+0x82b0>
    80002526:	00235797          	auipc	a5,0x235
    8000252a:	bf278793          	addi	a5,a5,-1038 # 80237118 <bcache+0x8268>
    8000252e:	00f48863          	beq	s1,a5,8000253e <bread+0x90>
    80002532:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002534:	40bc                	lw	a5,64(s1)
    80002536:	cf81                	beqz	a5,8000254e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002538:	64a4                	ld	s1,72(s1)
    8000253a:	fee49de3          	bne	s1,a4,80002534 <bread+0x86>
  panic("bget: no buffers");
    8000253e:	00006517          	auipc	a0,0x6
    80002542:	fa250513          	addi	a0,a0,-94 # 800084e0 <syscalls+0xc0>
    80002546:	00004097          	auipc	ra,0x4
    8000254a:	822080e7          	jalr	-2014(ra) # 80005d68 <panic>
      b->dev = dev;
    8000254e:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002552:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002556:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000255a:	4785                	li	a5,1
    8000255c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000255e:	0022d517          	auipc	a0,0x22d
    80002562:	95250513          	addi	a0,a0,-1710 # 8022eeb0 <bcache>
    80002566:	00004097          	auipc	ra,0x4
    8000256a:	e00080e7          	jalr	-512(ra) # 80006366 <release>
      acquiresleep(&b->lock);
    8000256e:	01048513          	addi	a0,s1,16
    80002572:	00001097          	auipc	ra,0x1
    80002576:	408080e7          	jalr	1032(ra) # 8000397a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000257a:	409c                	lw	a5,0(s1)
    8000257c:	cb89                	beqz	a5,8000258e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000257e:	8526                	mv	a0,s1
    80002580:	70a2                	ld	ra,40(sp)
    80002582:	7402                	ld	s0,32(sp)
    80002584:	64e2                	ld	s1,24(sp)
    80002586:	6942                	ld	s2,16(sp)
    80002588:	69a2                	ld	s3,8(sp)
    8000258a:	6145                	addi	sp,sp,48
    8000258c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000258e:	4581                	li	a1,0
    80002590:	8526                	mv	a0,s1
    80002592:	00003097          	auipc	ra,0x3
    80002596:	f14080e7          	jalr	-236(ra) # 800054a6 <virtio_disk_rw>
    b->valid = 1;
    8000259a:	4785                	li	a5,1
    8000259c:	c09c                	sw	a5,0(s1)
  return b;
    8000259e:	b7c5                	j	8000257e <bread+0xd0>

00000000800025a0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800025a0:	1101                	addi	sp,sp,-32
    800025a2:	ec06                	sd	ra,24(sp)
    800025a4:	e822                	sd	s0,16(sp)
    800025a6:	e426                	sd	s1,8(sp)
    800025a8:	1000                	addi	s0,sp,32
    800025aa:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800025ac:	0541                	addi	a0,a0,16
    800025ae:	00001097          	auipc	ra,0x1
    800025b2:	466080e7          	jalr	1126(ra) # 80003a14 <holdingsleep>
    800025b6:	cd01                	beqz	a0,800025ce <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800025b8:	4585                	li	a1,1
    800025ba:	8526                	mv	a0,s1
    800025bc:	00003097          	auipc	ra,0x3
    800025c0:	eea080e7          	jalr	-278(ra) # 800054a6 <virtio_disk_rw>
}
    800025c4:	60e2                	ld	ra,24(sp)
    800025c6:	6442                	ld	s0,16(sp)
    800025c8:	64a2                	ld	s1,8(sp)
    800025ca:	6105                	addi	sp,sp,32
    800025cc:	8082                	ret
    panic("bwrite");
    800025ce:	00006517          	auipc	a0,0x6
    800025d2:	f2a50513          	addi	a0,a0,-214 # 800084f8 <syscalls+0xd8>
    800025d6:	00003097          	auipc	ra,0x3
    800025da:	792080e7          	jalr	1938(ra) # 80005d68 <panic>

00000000800025de <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800025de:	1101                	addi	sp,sp,-32
    800025e0:	ec06                	sd	ra,24(sp)
    800025e2:	e822                	sd	s0,16(sp)
    800025e4:	e426                	sd	s1,8(sp)
    800025e6:	e04a                	sd	s2,0(sp)
    800025e8:	1000                	addi	s0,sp,32
    800025ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800025ec:	01050913          	addi	s2,a0,16
    800025f0:	854a                	mv	a0,s2
    800025f2:	00001097          	auipc	ra,0x1
    800025f6:	422080e7          	jalr	1058(ra) # 80003a14 <holdingsleep>
    800025fa:	c92d                	beqz	a0,8000266c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800025fc:	854a                	mv	a0,s2
    800025fe:	00001097          	auipc	ra,0x1
    80002602:	3d2080e7          	jalr	978(ra) # 800039d0 <releasesleep>

  acquire(&bcache.lock);
    80002606:	0022d517          	auipc	a0,0x22d
    8000260a:	8aa50513          	addi	a0,a0,-1878 # 8022eeb0 <bcache>
    8000260e:	00004097          	auipc	ra,0x4
    80002612:	ca4080e7          	jalr	-860(ra) # 800062b2 <acquire>
  b->refcnt--;
    80002616:	40bc                	lw	a5,64(s1)
    80002618:	37fd                	addiw	a5,a5,-1
    8000261a:	0007871b          	sext.w	a4,a5
    8000261e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002620:	eb05                	bnez	a4,80002650 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002622:	68bc                	ld	a5,80(s1)
    80002624:	64b8                	ld	a4,72(s1)
    80002626:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002628:	64bc                	ld	a5,72(s1)
    8000262a:	68b8                	ld	a4,80(s1)
    8000262c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000262e:	00235797          	auipc	a5,0x235
    80002632:	88278793          	addi	a5,a5,-1918 # 80236eb0 <bcache+0x8000>
    80002636:	2b87b703          	ld	a4,696(a5)
    8000263a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000263c:	00235717          	auipc	a4,0x235
    80002640:	adc70713          	addi	a4,a4,-1316 # 80237118 <bcache+0x8268>
    80002644:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002646:	2b87b703          	ld	a4,696(a5)
    8000264a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000264c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002650:	0022d517          	auipc	a0,0x22d
    80002654:	86050513          	addi	a0,a0,-1952 # 8022eeb0 <bcache>
    80002658:	00004097          	auipc	ra,0x4
    8000265c:	d0e080e7          	jalr	-754(ra) # 80006366 <release>
}
    80002660:	60e2                	ld	ra,24(sp)
    80002662:	6442                	ld	s0,16(sp)
    80002664:	64a2                	ld	s1,8(sp)
    80002666:	6902                	ld	s2,0(sp)
    80002668:	6105                	addi	sp,sp,32
    8000266a:	8082                	ret
    panic("brelse");
    8000266c:	00006517          	auipc	a0,0x6
    80002670:	e9450513          	addi	a0,a0,-364 # 80008500 <syscalls+0xe0>
    80002674:	00003097          	auipc	ra,0x3
    80002678:	6f4080e7          	jalr	1780(ra) # 80005d68 <panic>

000000008000267c <bpin>:

void
bpin(struct buf *b) {
    8000267c:	1101                	addi	sp,sp,-32
    8000267e:	ec06                	sd	ra,24(sp)
    80002680:	e822                	sd	s0,16(sp)
    80002682:	e426                	sd	s1,8(sp)
    80002684:	1000                	addi	s0,sp,32
    80002686:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002688:	0022d517          	auipc	a0,0x22d
    8000268c:	82850513          	addi	a0,a0,-2008 # 8022eeb0 <bcache>
    80002690:	00004097          	auipc	ra,0x4
    80002694:	c22080e7          	jalr	-990(ra) # 800062b2 <acquire>
  b->refcnt++;
    80002698:	40bc                	lw	a5,64(s1)
    8000269a:	2785                	addiw	a5,a5,1
    8000269c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000269e:	0022d517          	auipc	a0,0x22d
    800026a2:	81250513          	addi	a0,a0,-2030 # 8022eeb0 <bcache>
    800026a6:	00004097          	auipc	ra,0x4
    800026aa:	cc0080e7          	jalr	-832(ra) # 80006366 <release>
}
    800026ae:	60e2                	ld	ra,24(sp)
    800026b0:	6442                	ld	s0,16(sp)
    800026b2:	64a2                	ld	s1,8(sp)
    800026b4:	6105                	addi	sp,sp,32
    800026b6:	8082                	ret

00000000800026b8 <bunpin>:

void
bunpin(struct buf *b) {
    800026b8:	1101                	addi	sp,sp,-32
    800026ba:	ec06                	sd	ra,24(sp)
    800026bc:	e822                	sd	s0,16(sp)
    800026be:	e426                	sd	s1,8(sp)
    800026c0:	1000                	addi	s0,sp,32
    800026c2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800026c4:	0022c517          	auipc	a0,0x22c
    800026c8:	7ec50513          	addi	a0,a0,2028 # 8022eeb0 <bcache>
    800026cc:	00004097          	auipc	ra,0x4
    800026d0:	be6080e7          	jalr	-1050(ra) # 800062b2 <acquire>
  b->refcnt--;
    800026d4:	40bc                	lw	a5,64(s1)
    800026d6:	37fd                	addiw	a5,a5,-1
    800026d8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800026da:	0022c517          	auipc	a0,0x22c
    800026de:	7d650513          	addi	a0,a0,2006 # 8022eeb0 <bcache>
    800026e2:	00004097          	auipc	ra,0x4
    800026e6:	c84080e7          	jalr	-892(ra) # 80006366 <release>
}
    800026ea:	60e2                	ld	ra,24(sp)
    800026ec:	6442                	ld	s0,16(sp)
    800026ee:	64a2                	ld	s1,8(sp)
    800026f0:	6105                	addi	sp,sp,32
    800026f2:	8082                	ret

00000000800026f4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800026f4:	1101                	addi	sp,sp,-32
    800026f6:	ec06                	sd	ra,24(sp)
    800026f8:	e822                	sd	s0,16(sp)
    800026fa:	e426                	sd	s1,8(sp)
    800026fc:	e04a                	sd	s2,0(sp)
    800026fe:	1000                	addi	s0,sp,32
    80002700:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002702:	00d5d59b          	srliw	a1,a1,0xd
    80002706:	00235797          	auipc	a5,0x235
    8000270a:	e867a783          	lw	a5,-378(a5) # 8023758c <sb+0x1c>
    8000270e:	9dbd                	addw	a1,a1,a5
    80002710:	00000097          	auipc	ra,0x0
    80002714:	d9e080e7          	jalr	-610(ra) # 800024ae <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002718:	0074f713          	andi	a4,s1,7
    8000271c:	4785                	li	a5,1
    8000271e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002722:	14ce                	slli	s1,s1,0x33
    80002724:	90d9                	srli	s1,s1,0x36
    80002726:	00950733          	add	a4,a0,s1
    8000272a:	05874703          	lbu	a4,88(a4)
    8000272e:	00e7f6b3          	and	a3,a5,a4
    80002732:	c69d                	beqz	a3,80002760 <bfree+0x6c>
    80002734:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002736:	94aa                	add	s1,s1,a0
    80002738:	fff7c793          	not	a5,a5
    8000273c:	8ff9                	and	a5,a5,a4
    8000273e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002742:	00001097          	auipc	ra,0x1
    80002746:	118080e7          	jalr	280(ra) # 8000385a <log_write>
  brelse(bp);
    8000274a:	854a                	mv	a0,s2
    8000274c:	00000097          	auipc	ra,0x0
    80002750:	e92080e7          	jalr	-366(ra) # 800025de <brelse>
}
    80002754:	60e2                	ld	ra,24(sp)
    80002756:	6442                	ld	s0,16(sp)
    80002758:	64a2                	ld	s1,8(sp)
    8000275a:	6902                	ld	s2,0(sp)
    8000275c:	6105                	addi	sp,sp,32
    8000275e:	8082                	ret
    panic("freeing free block");
    80002760:	00006517          	auipc	a0,0x6
    80002764:	da850513          	addi	a0,a0,-600 # 80008508 <syscalls+0xe8>
    80002768:	00003097          	auipc	ra,0x3
    8000276c:	600080e7          	jalr	1536(ra) # 80005d68 <panic>

0000000080002770 <balloc>:
{
    80002770:	711d                	addi	sp,sp,-96
    80002772:	ec86                	sd	ra,88(sp)
    80002774:	e8a2                	sd	s0,80(sp)
    80002776:	e4a6                	sd	s1,72(sp)
    80002778:	e0ca                	sd	s2,64(sp)
    8000277a:	fc4e                	sd	s3,56(sp)
    8000277c:	f852                	sd	s4,48(sp)
    8000277e:	f456                	sd	s5,40(sp)
    80002780:	f05a                	sd	s6,32(sp)
    80002782:	ec5e                	sd	s7,24(sp)
    80002784:	e862                	sd	s8,16(sp)
    80002786:	e466                	sd	s9,8(sp)
    80002788:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000278a:	00235797          	auipc	a5,0x235
    8000278e:	dea7a783          	lw	a5,-534(a5) # 80237574 <sb+0x4>
    80002792:	cbd1                	beqz	a5,80002826 <balloc+0xb6>
    80002794:	8baa                	mv	s7,a0
    80002796:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002798:	00235b17          	auipc	s6,0x235
    8000279c:	dd8b0b13          	addi	s6,s6,-552 # 80237570 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027a0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800027a2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027a4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800027a6:	6c89                	lui	s9,0x2
    800027a8:	a831                	j	800027c4 <balloc+0x54>
    brelse(bp);
    800027aa:	854a                	mv	a0,s2
    800027ac:	00000097          	auipc	ra,0x0
    800027b0:	e32080e7          	jalr	-462(ra) # 800025de <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800027b4:	015c87bb          	addw	a5,s9,s5
    800027b8:	00078a9b          	sext.w	s5,a5
    800027bc:	004b2703          	lw	a4,4(s6)
    800027c0:	06eaf363          	bgeu	s5,a4,80002826 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800027c4:	41fad79b          	sraiw	a5,s5,0x1f
    800027c8:	0137d79b          	srliw	a5,a5,0x13
    800027cc:	015787bb          	addw	a5,a5,s5
    800027d0:	40d7d79b          	sraiw	a5,a5,0xd
    800027d4:	01cb2583          	lw	a1,28(s6)
    800027d8:	9dbd                	addw	a1,a1,a5
    800027da:	855e                	mv	a0,s7
    800027dc:	00000097          	auipc	ra,0x0
    800027e0:	cd2080e7          	jalr	-814(ra) # 800024ae <bread>
    800027e4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027e6:	004b2503          	lw	a0,4(s6)
    800027ea:	000a849b          	sext.w	s1,s5
    800027ee:	8662                	mv	a2,s8
    800027f0:	faa4fde3          	bgeu	s1,a0,800027aa <balloc+0x3a>
      m = 1 << (bi % 8);
    800027f4:	41f6579b          	sraiw	a5,a2,0x1f
    800027f8:	01d7d69b          	srliw	a3,a5,0x1d
    800027fc:	00c6873b          	addw	a4,a3,a2
    80002800:	00777793          	andi	a5,a4,7
    80002804:	9f95                	subw	a5,a5,a3
    80002806:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000280a:	4037571b          	sraiw	a4,a4,0x3
    8000280e:	00e906b3          	add	a3,s2,a4
    80002812:	0586c683          	lbu	a3,88(a3)
    80002816:	00d7f5b3          	and	a1,a5,a3
    8000281a:	cd91                	beqz	a1,80002836 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000281c:	2605                	addiw	a2,a2,1
    8000281e:	2485                	addiw	s1,s1,1
    80002820:	fd4618e3          	bne	a2,s4,800027f0 <balloc+0x80>
    80002824:	b759                	j	800027aa <balloc+0x3a>
  panic("balloc: out of blocks");
    80002826:	00006517          	auipc	a0,0x6
    8000282a:	cfa50513          	addi	a0,a0,-774 # 80008520 <syscalls+0x100>
    8000282e:	00003097          	auipc	ra,0x3
    80002832:	53a080e7          	jalr	1338(ra) # 80005d68 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002836:	974a                	add	a4,a4,s2
    80002838:	8fd5                	or	a5,a5,a3
    8000283a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000283e:	854a                	mv	a0,s2
    80002840:	00001097          	auipc	ra,0x1
    80002844:	01a080e7          	jalr	26(ra) # 8000385a <log_write>
        brelse(bp);
    80002848:	854a                	mv	a0,s2
    8000284a:	00000097          	auipc	ra,0x0
    8000284e:	d94080e7          	jalr	-620(ra) # 800025de <brelse>
  bp = bread(dev, bno);
    80002852:	85a6                	mv	a1,s1
    80002854:	855e                	mv	a0,s7
    80002856:	00000097          	auipc	ra,0x0
    8000285a:	c58080e7          	jalr	-936(ra) # 800024ae <bread>
    8000285e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002860:	40000613          	li	a2,1024
    80002864:	4581                	li	a1,0
    80002866:	05850513          	addi	a0,a0,88
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	a4a080e7          	jalr	-1462(ra) # 800002b4 <memset>
  log_write(bp);
    80002872:	854a                	mv	a0,s2
    80002874:	00001097          	auipc	ra,0x1
    80002878:	fe6080e7          	jalr	-26(ra) # 8000385a <log_write>
  brelse(bp);
    8000287c:	854a                	mv	a0,s2
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	d60080e7          	jalr	-672(ra) # 800025de <brelse>
}
    80002886:	8526                	mv	a0,s1
    80002888:	60e6                	ld	ra,88(sp)
    8000288a:	6446                	ld	s0,80(sp)
    8000288c:	64a6                	ld	s1,72(sp)
    8000288e:	6906                	ld	s2,64(sp)
    80002890:	79e2                	ld	s3,56(sp)
    80002892:	7a42                	ld	s4,48(sp)
    80002894:	7aa2                	ld	s5,40(sp)
    80002896:	7b02                	ld	s6,32(sp)
    80002898:	6be2                	ld	s7,24(sp)
    8000289a:	6c42                	ld	s8,16(sp)
    8000289c:	6ca2                	ld	s9,8(sp)
    8000289e:	6125                	addi	sp,sp,96
    800028a0:	8082                	ret

00000000800028a2 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800028a2:	7179                	addi	sp,sp,-48
    800028a4:	f406                	sd	ra,40(sp)
    800028a6:	f022                	sd	s0,32(sp)
    800028a8:	ec26                	sd	s1,24(sp)
    800028aa:	e84a                	sd	s2,16(sp)
    800028ac:	e44e                	sd	s3,8(sp)
    800028ae:	e052                	sd	s4,0(sp)
    800028b0:	1800                	addi	s0,sp,48
    800028b2:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800028b4:	47ad                	li	a5,11
    800028b6:	04b7fe63          	bgeu	a5,a1,80002912 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800028ba:	ff45849b          	addiw	s1,a1,-12
    800028be:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800028c2:	0ff00793          	li	a5,255
    800028c6:	0ae7e363          	bltu	a5,a4,8000296c <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800028ca:	08052583          	lw	a1,128(a0)
    800028ce:	c5ad                	beqz	a1,80002938 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800028d0:	00092503          	lw	a0,0(s2)
    800028d4:	00000097          	auipc	ra,0x0
    800028d8:	bda080e7          	jalr	-1062(ra) # 800024ae <bread>
    800028dc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800028de:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800028e2:	02049593          	slli	a1,s1,0x20
    800028e6:	9181                	srli	a1,a1,0x20
    800028e8:	058a                	slli	a1,a1,0x2
    800028ea:	00b784b3          	add	s1,a5,a1
    800028ee:	0004a983          	lw	s3,0(s1)
    800028f2:	04098d63          	beqz	s3,8000294c <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800028f6:	8552                	mv	a0,s4
    800028f8:	00000097          	auipc	ra,0x0
    800028fc:	ce6080e7          	jalr	-794(ra) # 800025de <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002900:	854e                	mv	a0,s3
    80002902:	70a2                	ld	ra,40(sp)
    80002904:	7402                	ld	s0,32(sp)
    80002906:	64e2                	ld	s1,24(sp)
    80002908:	6942                	ld	s2,16(sp)
    8000290a:	69a2                	ld	s3,8(sp)
    8000290c:	6a02                	ld	s4,0(sp)
    8000290e:	6145                	addi	sp,sp,48
    80002910:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80002912:	02059493          	slli	s1,a1,0x20
    80002916:	9081                	srli	s1,s1,0x20
    80002918:	048a                	slli	s1,s1,0x2
    8000291a:	94aa                	add	s1,s1,a0
    8000291c:	0504a983          	lw	s3,80(s1)
    80002920:	fe0990e3          	bnez	s3,80002900 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80002924:	4108                	lw	a0,0(a0)
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	e4a080e7          	jalr	-438(ra) # 80002770 <balloc>
    8000292e:	0005099b          	sext.w	s3,a0
    80002932:	0534a823          	sw	s3,80(s1)
    80002936:	b7e9                	j	80002900 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80002938:	4108                	lw	a0,0(a0)
    8000293a:	00000097          	auipc	ra,0x0
    8000293e:	e36080e7          	jalr	-458(ra) # 80002770 <balloc>
    80002942:	0005059b          	sext.w	a1,a0
    80002946:	08b92023          	sw	a1,128(s2)
    8000294a:	b759                	j	800028d0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000294c:	00092503          	lw	a0,0(s2)
    80002950:	00000097          	auipc	ra,0x0
    80002954:	e20080e7          	jalr	-480(ra) # 80002770 <balloc>
    80002958:	0005099b          	sext.w	s3,a0
    8000295c:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80002960:	8552                	mv	a0,s4
    80002962:	00001097          	auipc	ra,0x1
    80002966:	ef8080e7          	jalr	-264(ra) # 8000385a <log_write>
    8000296a:	b771                	j	800028f6 <bmap+0x54>
  panic("bmap: out of range");
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	bcc50513          	addi	a0,a0,-1076 # 80008538 <syscalls+0x118>
    80002974:	00003097          	auipc	ra,0x3
    80002978:	3f4080e7          	jalr	1012(ra) # 80005d68 <panic>

000000008000297c <iget>:
{
    8000297c:	7179                	addi	sp,sp,-48
    8000297e:	f406                	sd	ra,40(sp)
    80002980:	f022                	sd	s0,32(sp)
    80002982:	ec26                	sd	s1,24(sp)
    80002984:	e84a                	sd	s2,16(sp)
    80002986:	e44e                	sd	s3,8(sp)
    80002988:	e052                	sd	s4,0(sp)
    8000298a:	1800                	addi	s0,sp,48
    8000298c:	89aa                	mv	s3,a0
    8000298e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002990:	00235517          	auipc	a0,0x235
    80002994:	c0050513          	addi	a0,a0,-1024 # 80237590 <itable>
    80002998:	00004097          	auipc	ra,0x4
    8000299c:	91a080e7          	jalr	-1766(ra) # 800062b2 <acquire>
  empty = 0;
    800029a0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800029a2:	00235497          	auipc	s1,0x235
    800029a6:	c0648493          	addi	s1,s1,-1018 # 802375a8 <itable+0x18>
    800029aa:	00236697          	auipc	a3,0x236
    800029ae:	68e68693          	addi	a3,a3,1678 # 80239038 <log>
    800029b2:	a039                	j	800029c0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800029b4:	02090b63          	beqz	s2,800029ea <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800029b8:	08848493          	addi	s1,s1,136
    800029bc:	02d48a63          	beq	s1,a3,800029f0 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800029c0:	449c                	lw	a5,8(s1)
    800029c2:	fef059e3          	blez	a5,800029b4 <iget+0x38>
    800029c6:	4098                	lw	a4,0(s1)
    800029c8:	ff3716e3          	bne	a4,s3,800029b4 <iget+0x38>
    800029cc:	40d8                	lw	a4,4(s1)
    800029ce:	ff4713e3          	bne	a4,s4,800029b4 <iget+0x38>
      ip->ref++;
    800029d2:	2785                	addiw	a5,a5,1
    800029d4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800029d6:	00235517          	auipc	a0,0x235
    800029da:	bba50513          	addi	a0,a0,-1094 # 80237590 <itable>
    800029de:	00004097          	auipc	ra,0x4
    800029e2:	988080e7          	jalr	-1656(ra) # 80006366 <release>
      return ip;
    800029e6:	8926                	mv	s2,s1
    800029e8:	a03d                	j	80002a16 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800029ea:	f7f9                	bnez	a5,800029b8 <iget+0x3c>
    800029ec:	8926                	mv	s2,s1
    800029ee:	b7e9                	j	800029b8 <iget+0x3c>
  if(empty == 0)
    800029f0:	02090c63          	beqz	s2,80002a28 <iget+0xac>
  ip->dev = dev;
    800029f4:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800029f8:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800029fc:	4785                	li	a5,1
    800029fe:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002a02:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002a06:	00235517          	auipc	a0,0x235
    80002a0a:	b8a50513          	addi	a0,a0,-1142 # 80237590 <itable>
    80002a0e:	00004097          	auipc	ra,0x4
    80002a12:	958080e7          	jalr	-1704(ra) # 80006366 <release>
}
    80002a16:	854a                	mv	a0,s2
    80002a18:	70a2                	ld	ra,40(sp)
    80002a1a:	7402                	ld	s0,32(sp)
    80002a1c:	64e2                	ld	s1,24(sp)
    80002a1e:	6942                	ld	s2,16(sp)
    80002a20:	69a2                	ld	s3,8(sp)
    80002a22:	6a02                	ld	s4,0(sp)
    80002a24:	6145                	addi	sp,sp,48
    80002a26:	8082                	ret
    panic("iget: no inodes");
    80002a28:	00006517          	auipc	a0,0x6
    80002a2c:	b2850513          	addi	a0,a0,-1240 # 80008550 <syscalls+0x130>
    80002a30:	00003097          	auipc	ra,0x3
    80002a34:	338080e7          	jalr	824(ra) # 80005d68 <panic>

0000000080002a38 <fsinit>:
fsinit(int dev) {
    80002a38:	7179                	addi	sp,sp,-48
    80002a3a:	f406                	sd	ra,40(sp)
    80002a3c:	f022                	sd	s0,32(sp)
    80002a3e:	ec26                	sd	s1,24(sp)
    80002a40:	e84a                	sd	s2,16(sp)
    80002a42:	e44e                	sd	s3,8(sp)
    80002a44:	1800                	addi	s0,sp,48
    80002a46:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002a48:	4585                	li	a1,1
    80002a4a:	00000097          	auipc	ra,0x0
    80002a4e:	a64080e7          	jalr	-1436(ra) # 800024ae <bread>
    80002a52:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002a54:	00235997          	auipc	s3,0x235
    80002a58:	b1c98993          	addi	s3,s3,-1252 # 80237570 <sb>
    80002a5c:	02000613          	li	a2,32
    80002a60:	05850593          	addi	a1,a0,88
    80002a64:	854e                	mv	a0,s3
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	8ae080e7          	jalr	-1874(ra) # 80000314 <memmove>
  brelse(bp);
    80002a6e:	8526                	mv	a0,s1
    80002a70:	00000097          	auipc	ra,0x0
    80002a74:	b6e080e7          	jalr	-1170(ra) # 800025de <brelse>
  if(sb.magic != FSMAGIC)
    80002a78:	0009a703          	lw	a4,0(s3)
    80002a7c:	102037b7          	lui	a5,0x10203
    80002a80:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002a84:	02f71263          	bne	a4,a5,80002aa8 <fsinit+0x70>
  initlog(dev, &sb);
    80002a88:	00235597          	auipc	a1,0x235
    80002a8c:	ae858593          	addi	a1,a1,-1304 # 80237570 <sb>
    80002a90:	854a                	mv	a0,s2
    80002a92:	00001097          	auipc	ra,0x1
    80002a96:	b4c080e7          	jalr	-1204(ra) # 800035de <initlog>
}
    80002a9a:	70a2                	ld	ra,40(sp)
    80002a9c:	7402                	ld	s0,32(sp)
    80002a9e:	64e2                	ld	s1,24(sp)
    80002aa0:	6942                	ld	s2,16(sp)
    80002aa2:	69a2                	ld	s3,8(sp)
    80002aa4:	6145                	addi	sp,sp,48
    80002aa6:	8082                	ret
    panic("invalid file system");
    80002aa8:	00006517          	auipc	a0,0x6
    80002aac:	ab850513          	addi	a0,a0,-1352 # 80008560 <syscalls+0x140>
    80002ab0:	00003097          	auipc	ra,0x3
    80002ab4:	2b8080e7          	jalr	696(ra) # 80005d68 <panic>

0000000080002ab8 <iinit>:
{
    80002ab8:	7179                	addi	sp,sp,-48
    80002aba:	f406                	sd	ra,40(sp)
    80002abc:	f022                	sd	s0,32(sp)
    80002abe:	ec26                	sd	s1,24(sp)
    80002ac0:	e84a                	sd	s2,16(sp)
    80002ac2:	e44e                	sd	s3,8(sp)
    80002ac4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002ac6:	00006597          	auipc	a1,0x6
    80002aca:	ab258593          	addi	a1,a1,-1358 # 80008578 <syscalls+0x158>
    80002ace:	00235517          	auipc	a0,0x235
    80002ad2:	ac250513          	addi	a0,a0,-1342 # 80237590 <itable>
    80002ad6:	00003097          	auipc	ra,0x3
    80002ada:	74c080e7          	jalr	1868(ra) # 80006222 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002ade:	00235497          	auipc	s1,0x235
    80002ae2:	ada48493          	addi	s1,s1,-1318 # 802375b8 <itable+0x28>
    80002ae6:	00236997          	auipc	s3,0x236
    80002aea:	56298993          	addi	s3,s3,1378 # 80239048 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002aee:	00006917          	auipc	s2,0x6
    80002af2:	a9290913          	addi	s2,s2,-1390 # 80008580 <syscalls+0x160>
    80002af6:	85ca                	mv	a1,s2
    80002af8:	8526                	mv	a0,s1
    80002afa:	00001097          	auipc	ra,0x1
    80002afe:	e46080e7          	jalr	-442(ra) # 80003940 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002b02:	08848493          	addi	s1,s1,136
    80002b06:	ff3498e3          	bne	s1,s3,80002af6 <iinit+0x3e>
}
    80002b0a:	70a2                	ld	ra,40(sp)
    80002b0c:	7402                	ld	s0,32(sp)
    80002b0e:	64e2                	ld	s1,24(sp)
    80002b10:	6942                	ld	s2,16(sp)
    80002b12:	69a2                	ld	s3,8(sp)
    80002b14:	6145                	addi	sp,sp,48
    80002b16:	8082                	ret

0000000080002b18 <ialloc>:
{
    80002b18:	715d                	addi	sp,sp,-80
    80002b1a:	e486                	sd	ra,72(sp)
    80002b1c:	e0a2                	sd	s0,64(sp)
    80002b1e:	fc26                	sd	s1,56(sp)
    80002b20:	f84a                	sd	s2,48(sp)
    80002b22:	f44e                	sd	s3,40(sp)
    80002b24:	f052                	sd	s4,32(sp)
    80002b26:	ec56                	sd	s5,24(sp)
    80002b28:	e85a                	sd	s6,16(sp)
    80002b2a:	e45e                	sd	s7,8(sp)
    80002b2c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002b2e:	00235717          	auipc	a4,0x235
    80002b32:	a4e72703          	lw	a4,-1458(a4) # 8023757c <sb+0xc>
    80002b36:	4785                	li	a5,1
    80002b38:	04e7fa63          	bgeu	a5,a4,80002b8c <ialloc+0x74>
    80002b3c:	8aaa                	mv	s5,a0
    80002b3e:	8bae                	mv	s7,a1
    80002b40:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002b42:	00235a17          	auipc	s4,0x235
    80002b46:	a2ea0a13          	addi	s4,s4,-1490 # 80237570 <sb>
    80002b4a:	00048b1b          	sext.w	s6,s1
    80002b4e:	0044d593          	srli	a1,s1,0x4
    80002b52:	018a2783          	lw	a5,24(s4)
    80002b56:	9dbd                	addw	a1,a1,a5
    80002b58:	8556                	mv	a0,s5
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	954080e7          	jalr	-1708(ra) # 800024ae <bread>
    80002b62:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002b64:	05850993          	addi	s3,a0,88
    80002b68:	00f4f793          	andi	a5,s1,15
    80002b6c:	079a                	slli	a5,a5,0x6
    80002b6e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002b70:	00099783          	lh	a5,0(s3)
    80002b74:	c785                	beqz	a5,80002b9c <ialloc+0x84>
    brelse(bp);
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	a68080e7          	jalr	-1432(ra) # 800025de <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002b7e:	0485                	addi	s1,s1,1
    80002b80:	00ca2703          	lw	a4,12(s4)
    80002b84:	0004879b          	sext.w	a5,s1
    80002b88:	fce7e1e3          	bltu	a5,a4,80002b4a <ialloc+0x32>
  panic("ialloc: no inodes");
    80002b8c:	00006517          	auipc	a0,0x6
    80002b90:	9fc50513          	addi	a0,a0,-1540 # 80008588 <syscalls+0x168>
    80002b94:	00003097          	auipc	ra,0x3
    80002b98:	1d4080e7          	jalr	468(ra) # 80005d68 <panic>
      memset(dip, 0, sizeof(*dip));
    80002b9c:	04000613          	li	a2,64
    80002ba0:	4581                	li	a1,0
    80002ba2:	854e                	mv	a0,s3
    80002ba4:	ffffd097          	auipc	ra,0xffffd
    80002ba8:	710080e7          	jalr	1808(ra) # 800002b4 <memset>
      dip->type = type;
    80002bac:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002bb0:	854a                	mv	a0,s2
    80002bb2:	00001097          	auipc	ra,0x1
    80002bb6:	ca8080e7          	jalr	-856(ra) # 8000385a <log_write>
      brelse(bp);
    80002bba:	854a                	mv	a0,s2
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	a22080e7          	jalr	-1502(ra) # 800025de <brelse>
      return iget(dev, inum);
    80002bc4:	85da                	mv	a1,s6
    80002bc6:	8556                	mv	a0,s5
    80002bc8:	00000097          	auipc	ra,0x0
    80002bcc:	db4080e7          	jalr	-588(ra) # 8000297c <iget>
}
    80002bd0:	60a6                	ld	ra,72(sp)
    80002bd2:	6406                	ld	s0,64(sp)
    80002bd4:	74e2                	ld	s1,56(sp)
    80002bd6:	7942                	ld	s2,48(sp)
    80002bd8:	79a2                	ld	s3,40(sp)
    80002bda:	7a02                	ld	s4,32(sp)
    80002bdc:	6ae2                	ld	s5,24(sp)
    80002bde:	6b42                	ld	s6,16(sp)
    80002be0:	6ba2                	ld	s7,8(sp)
    80002be2:	6161                	addi	sp,sp,80
    80002be4:	8082                	ret

0000000080002be6 <iupdate>:
{
    80002be6:	1101                	addi	sp,sp,-32
    80002be8:	ec06                	sd	ra,24(sp)
    80002bea:	e822                	sd	s0,16(sp)
    80002bec:	e426                	sd	s1,8(sp)
    80002bee:	e04a                	sd	s2,0(sp)
    80002bf0:	1000                	addi	s0,sp,32
    80002bf2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002bf4:	415c                	lw	a5,4(a0)
    80002bf6:	0047d79b          	srliw	a5,a5,0x4
    80002bfa:	00235597          	auipc	a1,0x235
    80002bfe:	98e5a583          	lw	a1,-1650(a1) # 80237588 <sb+0x18>
    80002c02:	9dbd                	addw	a1,a1,a5
    80002c04:	4108                	lw	a0,0(a0)
    80002c06:	00000097          	auipc	ra,0x0
    80002c0a:	8a8080e7          	jalr	-1880(ra) # 800024ae <bread>
    80002c0e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002c10:	05850793          	addi	a5,a0,88
    80002c14:	40c8                	lw	a0,4(s1)
    80002c16:	893d                	andi	a0,a0,15
    80002c18:	051a                	slli	a0,a0,0x6
    80002c1a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002c1c:	04449703          	lh	a4,68(s1)
    80002c20:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002c24:	04649703          	lh	a4,70(s1)
    80002c28:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002c2c:	04849703          	lh	a4,72(s1)
    80002c30:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002c34:	04a49703          	lh	a4,74(s1)
    80002c38:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002c3c:	44f8                	lw	a4,76(s1)
    80002c3e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002c40:	03400613          	li	a2,52
    80002c44:	05048593          	addi	a1,s1,80
    80002c48:	0531                	addi	a0,a0,12
    80002c4a:	ffffd097          	auipc	ra,0xffffd
    80002c4e:	6ca080e7          	jalr	1738(ra) # 80000314 <memmove>
  log_write(bp);
    80002c52:	854a                	mv	a0,s2
    80002c54:	00001097          	auipc	ra,0x1
    80002c58:	c06080e7          	jalr	-1018(ra) # 8000385a <log_write>
  brelse(bp);
    80002c5c:	854a                	mv	a0,s2
    80002c5e:	00000097          	auipc	ra,0x0
    80002c62:	980080e7          	jalr	-1664(ra) # 800025de <brelse>
}
    80002c66:	60e2                	ld	ra,24(sp)
    80002c68:	6442                	ld	s0,16(sp)
    80002c6a:	64a2                	ld	s1,8(sp)
    80002c6c:	6902                	ld	s2,0(sp)
    80002c6e:	6105                	addi	sp,sp,32
    80002c70:	8082                	ret

0000000080002c72 <idup>:
{
    80002c72:	1101                	addi	sp,sp,-32
    80002c74:	ec06                	sd	ra,24(sp)
    80002c76:	e822                	sd	s0,16(sp)
    80002c78:	e426                	sd	s1,8(sp)
    80002c7a:	1000                	addi	s0,sp,32
    80002c7c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002c7e:	00235517          	auipc	a0,0x235
    80002c82:	91250513          	addi	a0,a0,-1774 # 80237590 <itable>
    80002c86:	00003097          	auipc	ra,0x3
    80002c8a:	62c080e7          	jalr	1580(ra) # 800062b2 <acquire>
  ip->ref++;
    80002c8e:	449c                	lw	a5,8(s1)
    80002c90:	2785                	addiw	a5,a5,1
    80002c92:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002c94:	00235517          	auipc	a0,0x235
    80002c98:	8fc50513          	addi	a0,a0,-1796 # 80237590 <itable>
    80002c9c:	00003097          	auipc	ra,0x3
    80002ca0:	6ca080e7          	jalr	1738(ra) # 80006366 <release>
}
    80002ca4:	8526                	mv	a0,s1
    80002ca6:	60e2                	ld	ra,24(sp)
    80002ca8:	6442                	ld	s0,16(sp)
    80002caa:	64a2                	ld	s1,8(sp)
    80002cac:	6105                	addi	sp,sp,32
    80002cae:	8082                	ret

0000000080002cb0 <ilock>:
{
    80002cb0:	1101                	addi	sp,sp,-32
    80002cb2:	ec06                	sd	ra,24(sp)
    80002cb4:	e822                	sd	s0,16(sp)
    80002cb6:	e426                	sd	s1,8(sp)
    80002cb8:	e04a                	sd	s2,0(sp)
    80002cba:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002cbc:	c115                	beqz	a0,80002ce0 <ilock+0x30>
    80002cbe:	84aa                	mv	s1,a0
    80002cc0:	451c                	lw	a5,8(a0)
    80002cc2:	00f05f63          	blez	a5,80002ce0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002cc6:	0541                	addi	a0,a0,16
    80002cc8:	00001097          	auipc	ra,0x1
    80002ccc:	cb2080e7          	jalr	-846(ra) # 8000397a <acquiresleep>
  if(ip->valid == 0){
    80002cd0:	40bc                	lw	a5,64(s1)
    80002cd2:	cf99                	beqz	a5,80002cf0 <ilock+0x40>
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6902                	ld	s2,0(sp)
    80002cdc:	6105                	addi	sp,sp,32
    80002cde:	8082                	ret
    panic("ilock");
    80002ce0:	00006517          	auipc	a0,0x6
    80002ce4:	8c050513          	addi	a0,a0,-1856 # 800085a0 <syscalls+0x180>
    80002ce8:	00003097          	auipc	ra,0x3
    80002cec:	080080e7          	jalr	128(ra) # 80005d68 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002cf0:	40dc                	lw	a5,4(s1)
    80002cf2:	0047d79b          	srliw	a5,a5,0x4
    80002cf6:	00235597          	auipc	a1,0x235
    80002cfa:	8925a583          	lw	a1,-1902(a1) # 80237588 <sb+0x18>
    80002cfe:	9dbd                	addw	a1,a1,a5
    80002d00:	4088                	lw	a0,0(s1)
    80002d02:	fffff097          	auipc	ra,0xfffff
    80002d06:	7ac080e7          	jalr	1964(ra) # 800024ae <bread>
    80002d0a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002d0c:	05850593          	addi	a1,a0,88
    80002d10:	40dc                	lw	a5,4(s1)
    80002d12:	8bbd                	andi	a5,a5,15
    80002d14:	079a                	slli	a5,a5,0x6
    80002d16:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002d18:	00059783          	lh	a5,0(a1)
    80002d1c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002d20:	00259783          	lh	a5,2(a1)
    80002d24:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002d28:	00459783          	lh	a5,4(a1)
    80002d2c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002d30:	00659783          	lh	a5,6(a1)
    80002d34:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002d38:	459c                	lw	a5,8(a1)
    80002d3a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002d3c:	03400613          	li	a2,52
    80002d40:	05b1                	addi	a1,a1,12
    80002d42:	05048513          	addi	a0,s1,80
    80002d46:	ffffd097          	auipc	ra,0xffffd
    80002d4a:	5ce080e7          	jalr	1486(ra) # 80000314 <memmove>
    brelse(bp);
    80002d4e:	854a                	mv	a0,s2
    80002d50:	00000097          	auipc	ra,0x0
    80002d54:	88e080e7          	jalr	-1906(ra) # 800025de <brelse>
    ip->valid = 1;
    80002d58:	4785                	li	a5,1
    80002d5a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002d5c:	04449783          	lh	a5,68(s1)
    80002d60:	fbb5                	bnez	a5,80002cd4 <ilock+0x24>
      panic("ilock: no type");
    80002d62:	00006517          	auipc	a0,0x6
    80002d66:	84650513          	addi	a0,a0,-1978 # 800085a8 <syscalls+0x188>
    80002d6a:	00003097          	auipc	ra,0x3
    80002d6e:	ffe080e7          	jalr	-2(ra) # 80005d68 <panic>

0000000080002d72 <iunlock>:
{
    80002d72:	1101                	addi	sp,sp,-32
    80002d74:	ec06                	sd	ra,24(sp)
    80002d76:	e822                	sd	s0,16(sp)
    80002d78:	e426                	sd	s1,8(sp)
    80002d7a:	e04a                	sd	s2,0(sp)
    80002d7c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002d7e:	c905                	beqz	a0,80002dae <iunlock+0x3c>
    80002d80:	84aa                	mv	s1,a0
    80002d82:	01050913          	addi	s2,a0,16
    80002d86:	854a                	mv	a0,s2
    80002d88:	00001097          	auipc	ra,0x1
    80002d8c:	c8c080e7          	jalr	-884(ra) # 80003a14 <holdingsleep>
    80002d90:	cd19                	beqz	a0,80002dae <iunlock+0x3c>
    80002d92:	449c                	lw	a5,8(s1)
    80002d94:	00f05d63          	blez	a5,80002dae <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002d98:	854a                	mv	a0,s2
    80002d9a:	00001097          	auipc	ra,0x1
    80002d9e:	c36080e7          	jalr	-970(ra) # 800039d0 <releasesleep>
}
    80002da2:	60e2                	ld	ra,24(sp)
    80002da4:	6442                	ld	s0,16(sp)
    80002da6:	64a2                	ld	s1,8(sp)
    80002da8:	6902                	ld	s2,0(sp)
    80002daa:	6105                	addi	sp,sp,32
    80002dac:	8082                	ret
    panic("iunlock");
    80002dae:	00006517          	auipc	a0,0x6
    80002db2:	80a50513          	addi	a0,a0,-2038 # 800085b8 <syscalls+0x198>
    80002db6:	00003097          	auipc	ra,0x3
    80002dba:	fb2080e7          	jalr	-78(ra) # 80005d68 <panic>

0000000080002dbe <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002dbe:	7179                	addi	sp,sp,-48
    80002dc0:	f406                	sd	ra,40(sp)
    80002dc2:	f022                	sd	s0,32(sp)
    80002dc4:	ec26                	sd	s1,24(sp)
    80002dc6:	e84a                	sd	s2,16(sp)
    80002dc8:	e44e                	sd	s3,8(sp)
    80002dca:	e052                	sd	s4,0(sp)
    80002dcc:	1800                	addi	s0,sp,48
    80002dce:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002dd0:	05050493          	addi	s1,a0,80
    80002dd4:	08050913          	addi	s2,a0,128
    80002dd8:	a021                	j	80002de0 <itrunc+0x22>
    80002dda:	0491                	addi	s1,s1,4
    80002ddc:	01248d63          	beq	s1,s2,80002df6 <itrunc+0x38>
    if(ip->addrs[i]){
    80002de0:	408c                	lw	a1,0(s1)
    80002de2:	dde5                	beqz	a1,80002dda <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002de4:	0009a503          	lw	a0,0(s3)
    80002de8:	00000097          	auipc	ra,0x0
    80002dec:	90c080e7          	jalr	-1780(ra) # 800026f4 <bfree>
      ip->addrs[i] = 0;
    80002df0:	0004a023          	sw	zero,0(s1)
    80002df4:	b7dd                	j	80002dda <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002df6:	0809a583          	lw	a1,128(s3)
    80002dfa:	e185                	bnez	a1,80002e1a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002dfc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002e00:	854e                	mv	a0,s3
    80002e02:	00000097          	auipc	ra,0x0
    80002e06:	de4080e7          	jalr	-540(ra) # 80002be6 <iupdate>
}
    80002e0a:	70a2                	ld	ra,40(sp)
    80002e0c:	7402                	ld	s0,32(sp)
    80002e0e:	64e2                	ld	s1,24(sp)
    80002e10:	6942                	ld	s2,16(sp)
    80002e12:	69a2                	ld	s3,8(sp)
    80002e14:	6a02                	ld	s4,0(sp)
    80002e16:	6145                	addi	sp,sp,48
    80002e18:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002e1a:	0009a503          	lw	a0,0(s3)
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	690080e7          	jalr	1680(ra) # 800024ae <bread>
    80002e26:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002e28:	05850493          	addi	s1,a0,88
    80002e2c:	45850913          	addi	s2,a0,1112
    80002e30:	a811                	j	80002e44 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002e32:	0009a503          	lw	a0,0(s3)
    80002e36:	00000097          	auipc	ra,0x0
    80002e3a:	8be080e7          	jalr	-1858(ra) # 800026f4 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002e3e:	0491                	addi	s1,s1,4
    80002e40:	01248563          	beq	s1,s2,80002e4a <itrunc+0x8c>
      if(a[j])
    80002e44:	408c                	lw	a1,0(s1)
    80002e46:	dde5                	beqz	a1,80002e3e <itrunc+0x80>
    80002e48:	b7ed                	j	80002e32 <itrunc+0x74>
    brelse(bp);
    80002e4a:	8552                	mv	a0,s4
    80002e4c:	fffff097          	auipc	ra,0xfffff
    80002e50:	792080e7          	jalr	1938(ra) # 800025de <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002e54:	0809a583          	lw	a1,128(s3)
    80002e58:	0009a503          	lw	a0,0(s3)
    80002e5c:	00000097          	auipc	ra,0x0
    80002e60:	898080e7          	jalr	-1896(ra) # 800026f4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002e64:	0809a023          	sw	zero,128(s3)
    80002e68:	bf51                	j	80002dfc <itrunc+0x3e>

0000000080002e6a <iput>:
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	e426                	sd	s1,8(sp)
    80002e72:	e04a                	sd	s2,0(sp)
    80002e74:	1000                	addi	s0,sp,32
    80002e76:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002e78:	00234517          	auipc	a0,0x234
    80002e7c:	71850513          	addi	a0,a0,1816 # 80237590 <itable>
    80002e80:	00003097          	auipc	ra,0x3
    80002e84:	432080e7          	jalr	1074(ra) # 800062b2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e88:	4498                	lw	a4,8(s1)
    80002e8a:	4785                	li	a5,1
    80002e8c:	02f70363          	beq	a4,a5,80002eb2 <iput+0x48>
  ip->ref--;
    80002e90:	449c                	lw	a5,8(s1)
    80002e92:	37fd                	addiw	a5,a5,-1
    80002e94:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002e96:	00234517          	auipc	a0,0x234
    80002e9a:	6fa50513          	addi	a0,a0,1786 # 80237590 <itable>
    80002e9e:	00003097          	auipc	ra,0x3
    80002ea2:	4c8080e7          	jalr	1224(ra) # 80006366 <release>
}
    80002ea6:	60e2                	ld	ra,24(sp)
    80002ea8:	6442                	ld	s0,16(sp)
    80002eaa:	64a2                	ld	s1,8(sp)
    80002eac:	6902                	ld	s2,0(sp)
    80002eae:	6105                	addi	sp,sp,32
    80002eb0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002eb2:	40bc                	lw	a5,64(s1)
    80002eb4:	dff1                	beqz	a5,80002e90 <iput+0x26>
    80002eb6:	04a49783          	lh	a5,74(s1)
    80002eba:	fbf9                	bnez	a5,80002e90 <iput+0x26>
    acquiresleep(&ip->lock);
    80002ebc:	01048913          	addi	s2,s1,16
    80002ec0:	854a                	mv	a0,s2
    80002ec2:	00001097          	auipc	ra,0x1
    80002ec6:	ab8080e7          	jalr	-1352(ra) # 8000397a <acquiresleep>
    release(&itable.lock);
    80002eca:	00234517          	auipc	a0,0x234
    80002ece:	6c650513          	addi	a0,a0,1734 # 80237590 <itable>
    80002ed2:	00003097          	auipc	ra,0x3
    80002ed6:	494080e7          	jalr	1172(ra) # 80006366 <release>
    itrunc(ip);
    80002eda:	8526                	mv	a0,s1
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	ee2080e7          	jalr	-286(ra) # 80002dbe <itrunc>
    ip->type = 0;
    80002ee4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002ee8:	8526                	mv	a0,s1
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	cfc080e7          	jalr	-772(ra) # 80002be6 <iupdate>
    ip->valid = 0;
    80002ef2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002ef6:	854a                	mv	a0,s2
    80002ef8:	00001097          	auipc	ra,0x1
    80002efc:	ad8080e7          	jalr	-1320(ra) # 800039d0 <releasesleep>
    acquire(&itable.lock);
    80002f00:	00234517          	auipc	a0,0x234
    80002f04:	69050513          	addi	a0,a0,1680 # 80237590 <itable>
    80002f08:	00003097          	auipc	ra,0x3
    80002f0c:	3aa080e7          	jalr	938(ra) # 800062b2 <acquire>
    80002f10:	b741                	j	80002e90 <iput+0x26>

0000000080002f12 <iunlockput>:
{
    80002f12:	1101                	addi	sp,sp,-32
    80002f14:	ec06                	sd	ra,24(sp)
    80002f16:	e822                	sd	s0,16(sp)
    80002f18:	e426                	sd	s1,8(sp)
    80002f1a:	1000                	addi	s0,sp,32
    80002f1c:	84aa                	mv	s1,a0
  iunlock(ip);
    80002f1e:	00000097          	auipc	ra,0x0
    80002f22:	e54080e7          	jalr	-428(ra) # 80002d72 <iunlock>
  iput(ip);
    80002f26:	8526                	mv	a0,s1
    80002f28:	00000097          	auipc	ra,0x0
    80002f2c:	f42080e7          	jalr	-190(ra) # 80002e6a <iput>
}
    80002f30:	60e2                	ld	ra,24(sp)
    80002f32:	6442                	ld	s0,16(sp)
    80002f34:	64a2                	ld	s1,8(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret

0000000080002f3a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002f3a:	1141                	addi	sp,sp,-16
    80002f3c:	e422                	sd	s0,8(sp)
    80002f3e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002f40:	411c                	lw	a5,0(a0)
    80002f42:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002f44:	415c                	lw	a5,4(a0)
    80002f46:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002f48:	04451783          	lh	a5,68(a0)
    80002f4c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002f50:	04a51783          	lh	a5,74(a0)
    80002f54:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002f58:	04c56783          	lwu	a5,76(a0)
    80002f5c:	e99c                	sd	a5,16(a1)
}
    80002f5e:	6422                	ld	s0,8(sp)
    80002f60:	0141                	addi	sp,sp,16
    80002f62:	8082                	ret

0000000080002f64 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002f64:	457c                	lw	a5,76(a0)
    80002f66:	0ed7e963          	bltu	a5,a3,80003058 <readi+0xf4>
{
    80002f6a:	7159                	addi	sp,sp,-112
    80002f6c:	f486                	sd	ra,104(sp)
    80002f6e:	f0a2                	sd	s0,96(sp)
    80002f70:	eca6                	sd	s1,88(sp)
    80002f72:	e8ca                	sd	s2,80(sp)
    80002f74:	e4ce                	sd	s3,72(sp)
    80002f76:	e0d2                	sd	s4,64(sp)
    80002f78:	fc56                	sd	s5,56(sp)
    80002f7a:	f85a                	sd	s6,48(sp)
    80002f7c:	f45e                	sd	s7,40(sp)
    80002f7e:	f062                	sd	s8,32(sp)
    80002f80:	ec66                	sd	s9,24(sp)
    80002f82:	e86a                	sd	s10,16(sp)
    80002f84:	e46e                	sd	s11,8(sp)
    80002f86:	1880                	addi	s0,sp,112
    80002f88:	8baa                	mv	s7,a0
    80002f8a:	8c2e                	mv	s8,a1
    80002f8c:	8ab2                	mv	s5,a2
    80002f8e:	84b6                	mv	s1,a3
    80002f90:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002f92:	9f35                	addw	a4,a4,a3
    return 0;
    80002f94:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002f96:	0ad76063          	bltu	a4,a3,80003036 <readi+0xd2>
  if(off + n > ip->size)
    80002f9a:	00e7f463          	bgeu	a5,a4,80002fa2 <readi+0x3e>
    n = ip->size - off;
    80002f9e:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002fa2:	0a0b0963          	beqz	s6,80003054 <readi+0xf0>
    80002fa6:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002fa8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002fac:	5cfd                	li	s9,-1
    80002fae:	a82d                	j	80002fe8 <readi+0x84>
    80002fb0:	020a1d93          	slli	s11,s4,0x20
    80002fb4:	020ddd93          	srli	s11,s11,0x20
    80002fb8:	05890613          	addi	a2,s2,88
    80002fbc:	86ee                	mv	a3,s11
    80002fbe:	963a                	add	a2,a2,a4
    80002fc0:	85d6                	mv	a1,s5
    80002fc2:	8562                	mv	a0,s8
    80002fc4:	fffff097          	auipc	ra,0xfffff
    80002fc8:	a68080e7          	jalr	-1432(ra) # 80001a2c <either_copyout>
    80002fcc:	05950d63          	beq	a0,s9,80003026 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002fd0:	854a                	mv	a0,s2
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	60c080e7          	jalr	1548(ra) # 800025de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002fda:	013a09bb          	addw	s3,s4,s3
    80002fde:	009a04bb          	addw	s1,s4,s1
    80002fe2:	9aee                	add	s5,s5,s11
    80002fe4:	0569f763          	bgeu	s3,s6,80003032 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002fe8:	000ba903          	lw	s2,0(s7)
    80002fec:	00a4d59b          	srliw	a1,s1,0xa
    80002ff0:	855e                	mv	a0,s7
    80002ff2:	00000097          	auipc	ra,0x0
    80002ff6:	8b0080e7          	jalr	-1872(ra) # 800028a2 <bmap>
    80002ffa:	0005059b          	sext.w	a1,a0
    80002ffe:	854a                	mv	a0,s2
    80003000:	fffff097          	auipc	ra,0xfffff
    80003004:	4ae080e7          	jalr	1198(ra) # 800024ae <bread>
    80003008:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000300a:	3ff4f713          	andi	a4,s1,1023
    8000300e:	40ed07bb          	subw	a5,s10,a4
    80003012:	413b06bb          	subw	a3,s6,s3
    80003016:	8a3e                	mv	s4,a5
    80003018:	2781                	sext.w	a5,a5
    8000301a:	0006861b          	sext.w	a2,a3
    8000301e:	f8f679e3          	bgeu	a2,a5,80002fb0 <readi+0x4c>
    80003022:	8a36                	mv	s4,a3
    80003024:	b771                	j	80002fb0 <readi+0x4c>
      brelse(bp);
    80003026:	854a                	mv	a0,s2
    80003028:	fffff097          	auipc	ra,0xfffff
    8000302c:	5b6080e7          	jalr	1462(ra) # 800025de <brelse>
      tot = -1;
    80003030:	59fd                	li	s3,-1
  }
  return tot;
    80003032:	0009851b          	sext.w	a0,s3
}
    80003036:	70a6                	ld	ra,104(sp)
    80003038:	7406                	ld	s0,96(sp)
    8000303a:	64e6                	ld	s1,88(sp)
    8000303c:	6946                	ld	s2,80(sp)
    8000303e:	69a6                	ld	s3,72(sp)
    80003040:	6a06                	ld	s4,64(sp)
    80003042:	7ae2                	ld	s5,56(sp)
    80003044:	7b42                	ld	s6,48(sp)
    80003046:	7ba2                	ld	s7,40(sp)
    80003048:	7c02                	ld	s8,32(sp)
    8000304a:	6ce2                	ld	s9,24(sp)
    8000304c:	6d42                	ld	s10,16(sp)
    8000304e:	6da2                	ld	s11,8(sp)
    80003050:	6165                	addi	sp,sp,112
    80003052:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003054:	89da                	mv	s3,s6
    80003056:	bff1                	j	80003032 <readi+0xce>
    return 0;
    80003058:	4501                	li	a0,0
}
    8000305a:	8082                	ret

000000008000305c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000305c:	457c                	lw	a5,76(a0)
    8000305e:	10d7e863          	bltu	a5,a3,8000316e <writei+0x112>
{
    80003062:	7159                	addi	sp,sp,-112
    80003064:	f486                	sd	ra,104(sp)
    80003066:	f0a2                	sd	s0,96(sp)
    80003068:	eca6                	sd	s1,88(sp)
    8000306a:	e8ca                	sd	s2,80(sp)
    8000306c:	e4ce                	sd	s3,72(sp)
    8000306e:	e0d2                	sd	s4,64(sp)
    80003070:	fc56                	sd	s5,56(sp)
    80003072:	f85a                	sd	s6,48(sp)
    80003074:	f45e                	sd	s7,40(sp)
    80003076:	f062                	sd	s8,32(sp)
    80003078:	ec66                	sd	s9,24(sp)
    8000307a:	e86a                	sd	s10,16(sp)
    8000307c:	e46e                	sd	s11,8(sp)
    8000307e:	1880                	addi	s0,sp,112
    80003080:	8b2a                	mv	s6,a0
    80003082:	8c2e                	mv	s8,a1
    80003084:	8ab2                	mv	s5,a2
    80003086:	8936                	mv	s2,a3
    80003088:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000308a:	00e687bb          	addw	a5,a3,a4
    8000308e:	0ed7e263          	bltu	a5,a3,80003172 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003092:	00043737          	lui	a4,0x43
    80003096:	0ef76063          	bltu	a4,a5,80003176 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000309a:	0c0b8863          	beqz	s7,8000316a <writei+0x10e>
    8000309e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800030a0:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800030a4:	5cfd                	li	s9,-1
    800030a6:	a091                	j	800030ea <writei+0x8e>
    800030a8:	02099d93          	slli	s11,s3,0x20
    800030ac:	020ddd93          	srli	s11,s11,0x20
    800030b0:	05848513          	addi	a0,s1,88
    800030b4:	86ee                	mv	a3,s11
    800030b6:	8656                	mv	a2,s5
    800030b8:	85e2                	mv	a1,s8
    800030ba:	953a                	add	a0,a0,a4
    800030bc:	fffff097          	auipc	ra,0xfffff
    800030c0:	9c6080e7          	jalr	-1594(ra) # 80001a82 <either_copyin>
    800030c4:	07950263          	beq	a0,s9,80003128 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800030c8:	8526                	mv	a0,s1
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	790080e7          	jalr	1936(ra) # 8000385a <log_write>
    brelse(bp);
    800030d2:	8526                	mv	a0,s1
    800030d4:	fffff097          	auipc	ra,0xfffff
    800030d8:	50a080e7          	jalr	1290(ra) # 800025de <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800030dc:	01498a3b          	addw	s4,s3,s4
    800030e0:	0129893b          	addw	s2,s3,s2
    800030e4:	9aee                	add	s5,s5,s11
    800030e6:	057a7663          	bgeu	s4,s7,80003132 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800030ea:	000b2483          	lw	s1,0(s6)
    800030ee:	00a9559b          	srliw	a1,s2,0xa
    800030f2:	855a                	mv	a0,s6
    800030f4:	fffff097          	auipc	ra,0xfffff
    800030f8:	7ae080e7          	jalr	1966(ra) # 800028a2 <bmap>
    800030fc:	0005059b          	sext.w	a1,a0
    80003100:	8526                	mv	a0,s1
    80003102:	fffff097          	auipc	ra,0xfffff
    80003106:	3ac080e7          	jalr	940(ra) # 800024ae <bread>
    8000310a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000310c:	3ff97713          	andi	a4,s2,1023
    80003110:	40ed07bb          	subw	a5,s10,a4
    80003114:	414b86bb          	subw	a3,s7,s4
    80003118:	89be                	mv	s3,a5
    8000311a:	2781                	sext.w	a5,a5
    8000311c:	0006861b          	sext.w	a2,a3
    80003120:	f8f674e3          	bgeu	a2,a5,800030a8 <writei+0x4c>
    80003124:	89b6                	mv	s3,a3
    80003126:	b749                	j	800030a8 <writei+0x4c>
      brelse(bp);
    80003128:	8526                	mv	a0,s1
    8000312a:	fffff097          	auipc	ra,0xfffff
    8000312e:	4b4080e7          	jalr	1204(ra) # 800025de <brelse>
  }

  if(off > ip->size)
    80003132:	04cb2783          	lw	a5,76(s6)
    80003136:	0127f463          	bgeu	a5,s2,8000313e <writei+0xe2>
    ip->size = off;
    8000313a:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000313e:	855a                	mv	a0,s6
    80003140:	00000097          	auipc	ra,0x0
    80003144:	aa6080e7          	jalr	-1370(ra) # 80002be6 <iupdate>

  return tot;
    80003148:	000a051b          	sext.w	a0,s4
}
    8000314c:	70a6                	ld	ra,104(sp)
    8000314e:	7406                	ld	s0,96(sp)
    80003150:	64e6                	ld	s1,88(sp)
    80003152:	6946                	ld	s2,80(sp)
    80003154:	69a6                	ld	s3,72(sp)
    80003156:	6a06                	ld	s4,64(sp)
    80003158:	7ae2                	ld	s5,56(sp)
    8000315a:	7b42                	ld	s6,48(sp)
    8000315c:	7ba2                	ld	s7,40(sp)
    8000315e:	7c02                	ld	s8,32(sp)
    80003160:	6ce2                	ld	s9,24(sp)
    80003162:	6d42                	ld	s10,16(sp)
    80003164:	6da2                	ld	s11,8(sp)
    80003166:	6165                	addi	sp,sp,112
    80003168:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000316a:	8a5e                	mv	s4,s7
    8000316c:	bfc9                	j	8000313e <writei+0xe2>
    return -1;
    8000316e:	557d                	li	a0,-1
}
    80003170:	8082                	ret
    return -1;
    80003172:	557d                	li	a0,-1
    80003174:	bfe1                	j	8000314c <writei+0xf0>
    return -1;
    80003176:	557d                	li	a0,-1
    80003178:	bfd1                	j	8000314c <writei+0xf0>

000000008000317a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000317a:	1141                	addi	sp,sp,-16
    8000317c:	e406                	sd	ra,8(sp)
    8000317e:	e022                	sd	s0,0(sp)
    80003180:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003182:	4639                	li	a2,14
    80003184:	ffffd097          	auipc	ra,0xffffd
    80003188:	208080e7          	jalr	520(ra) # 8000038c <strncmp>
}
    8000318c:	60a2                	ld	ra,8(sp)
    8000318e:	6402                	ld	s0,0(sp)
    80003190:	0141                	addi	sp,sp,16
    80003192:	8082                	ret

0000000080003194 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003194:	7139                	addi	sp,sp,-64
    80003196:	fc06                	sd	ra,56(sp)
    80003198:	f822                	sd	s0,48(sp)
    8000319a:	f426                	sd	s1,40(sp)
    8000319c:	f04a                	sd	s2,32(sp)
    8000319e:	ec4e                	sd	s3,24(sp)
    800031a0:	e852                	sd	s4,16(sp)
    800031a2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800031a4:	04451703          	lh	a4,68(a0)
    800031a8:	4785                	li	a5,1
    800031aa:	00f71a63          	bne	a4,a5,800031be <dirlookup+0x2a>
    800031ae:	892a                	mv	s2,a0
    800031b0:	89ae                	mv	s3,a1
    800031b2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800031b4:	457c                	lw	a5,76(a0)
    800031b6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800031b8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800031ba:	e79d                	bnez	a5,800031e8 <dirlookup+0x54>
    800031bc:	a8a5                	j	80003234 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800031be:	00005517          	auipc	a0,0x5
    800031c2:	40250513          	addi	a0,a0,1026 # 800085c0 <syscalls+0x1a0>
    800031c6:	00003097          	auipc	ra,0x3
    800031ca:	ba2080e7          	jalr	-1118(ra) # 80005d68 <panic>
      panic("dirlookup read");
    800031ce:	00005517          	auipc	a0,0x5
    800031d2:	40a50513          	addi	a0,a0,1034 # 800085d8 <syscalls+0x1b8>
    800031d6:	00003097          	auipc	ra,0x3
    800031da:	b92080e7          	jalr	-1134(ra) # 80005d68 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800031de:	24c1                	addiw	s1,s1,16
    800031e0:	04c92783          	lw	a5,76(s2)
    800031e4:	04f4f763          	bgeu	s1,a5,80003232 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800031e8:	4741                	li	a4,16
    800031ea:	86a6                	mv	a3,s1
    800031ec:	fc040613          	addi	a2,s0,-64
    800031f0:	4581                	li	a1,0
    800031f2:	854a                	mv	a0,s2
    800031f4:	00000097          	auipc	ra,0x0
    800031f8:	d70080e7          	jalr	-656(ra) # 80002f64 <readi>
    800031fc:	47c1                	li	a5,16
    800031fe:	fcf518e3          	bne	a0,a5,800031ce <dirlookup+0x3a>
    if(de.inum == 0)
    80003202:	fc045783          	lhu	a5,-64(s0)
    80003206:	dfe1                	beqz	a5,800031de <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003208:	fc240593          	addi	a1,s0,-62
    8000320c:	854e                	mv	a0,s3
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	f6c080e7          	jalr	-148(ra) # 8000317a <namecmp>
    80003216:	f561                	bnez	a0,800031de <dirlookup+0x4a>
      if(poff)
    80003218:	000a0463          	beqz	s4,80003220 <dirlookup+0x8c>
        *poff = off;
    8000321c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003220:	fc045583          	lhu	a1,-64(s0)
    80003224:	00092503          	lw	a0,0(s2)
    80003228:	fffff097          	auipc	ra,0xfffff
    8000322c:	754080e7          	jalr	1876(ra) # 8000297c <iget>
    80003230:	a011                	j	80003234 <dirlookup+0xa0>
  return 0;
    80003232:	4501                	li	a0,0
}
    80003234:	70e2                	ld	ra,56(sp)
    80003236:	7442                	ld	s0,48(sp)
    80003238:	74a2                	ld	s1,40(sp)
    8000323a:	7902                	ld	s2,32(sp)
    8000323c:	69e2                	ld	s3,24(sp)
    8000323e:	6a42                	ld	s4,16(sp)
    80003240:	6121                	addi	sp,sp,64
    80003242:	8082                	ret

0000000080003244 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003244:	711d                	addi	sp,sp,-96
    80003246:	ec86                	sd	ra,88(sp)
    80003248:	e8a2                	sd	s0,80(sp)
    8000324a:	e4a6                	sd	s1,72(sp)
    8000324c:	e0ca                	sd	s2,64(sp)
    8000324e:	fc4e                	sd	s3,56(sp)
    80003250:	f852                	sd	s4,48(sp)
    80003252:	f456                	sd	s5,40(sp)
    80003254:	f05a                	sd	s6,32(sp)
    80003256:	ec5e                	sd	s7,24(sp)
    80003258:	e862                	sd	s8,16(sp)
    8000325a:	e466                	sd	s9,8(sp)
    8000325c:	1080                	addi	s0,sp,96
    8000325e:	84aa                	mv	s1,a0
    80003260:	8b2e                	mv	s6,a1
    80003262:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003264:	00054703          	lbu	a4,0(a0)
    80003268:	02f00793          	li	a5,47
    8000326c:	02f70363          	beq	a4,a5,80003292 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003270:	ffffe097          	auipc	ra,0xffffe
    80003274:	d5c080e7          	jalr	-676(ra) # 80000fcc <myproc>
    80003278:	15053503          	ld	a0,336(a0)
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	9f6080e7          	jalr	-1546(ra) # 80002c72 <idup>
    80003284:	89aa                	mv	s3,a0
  while(*path == '/')
    80003286:	02f00913          	li	s2,47
  len = path - s;
    8000328a:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000328c:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000328e:	4c05                	li	s8,1
    80003290:	a865                	j	80003348 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003292:	4585                	li	a1,1
    80003294:	4505                	li	a0,1
    80003296:	fffff097          	auipc	ra,0xfffff
    8000329a:	6e6080e7          	jalr	1766(ra) # 8000297c <iget>
    8000329e:	89aa                	mv	s3,a0
    800032a0:	b7dd                	j	80003286 <namex+0x42>
      iunlockput(ip);
    800032a2:	854e                	mv	a0,s3
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	c6e080e7          	jalr	-914(ra) # 80002f12 <iunlockput>
      return 0;
    800032ac:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800032ae:	854e                	mv	a0,s3
    800032b0:	60e6                	ld	ra,88(sp)
    800032b2:	6446                	ld	s0,80(sp)
    800032b4:	64a6                	ld	s1,72(sp)
    800032b6:	6906                	ld	s2,64(sp)
    800032b8:	79e2                	ld	s3,56(sp)
    800032ba:	7a42                	ld	s4,48(sp)
    800032bc:	7aa2                	ld	s5,40(sp)
    800032be:	7b02                	ld	s6,32(sp)
    800032c0:	6be2                	ld	s7,24(sp)
    800032c2:	6c42                	ld	s8,16(sp)
    800032c4:	6ca2                	ld	s9,8(sp)
    800032c6:	6125                	addi	sp,sp,96
    800032c8:	8082                	ret
      iunlock(ip);
    800032ca:	854e                	mv	a0,s3
    800032cc:	00000097          	auipc	ra,0x0
    800032d0:	aa6080e7          	jalr	-1370(ra) # 80002d72 <iunlock>
      return ip;
    800032d4:	bfe9                	j	800032ae <namex+0x6a>
      iunlockput(ip);
    800032d6:	854e                	mv	a0,s3
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	c3a080e7          	jalr	-966(ra) # 80002f12 <iunlockput>
      return 0;
    800032e0:	89d2                	mv	s3,s4
    800032e2:	b7f1                	j	800032ae <namex+0x6a>
  len = path - s;
    800032e4:	40b48633          	sub	a2,s1,a1
    800032e8:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800032ec:	094cd463          	bge	s9,s4,80003374 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800032f0:	4639                	li	a2,14
    800032f2:	8556                	mv	a0,s5
    800032f4:	ffffd097          	auipc	ra,0xffffd
    800032f8:	020080e7          	jalr	32(ra) # 80000314 <memmove>
  while(*path == '/')
    800032fc:	0004c783          	lbu	a5,0(s1)
    80003300:	01279763          	bne	a5,s2,8000330e <namex+0xca>
    path++;
    80003304:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003306:	0004c783          	lbu	a5,0(s1)
    8000330a:	ff278de3          	beq	a5,s2,80003304 <namex+0xc0>
    ilock(ip);
    8000330e:	854e                	mv	a0,s3
    80003310:	00000097          	auipc	ra,0x0
    80003314:	9a0080e7          	jalr	-1632(ra) # 80002cb0 <ilock>
    if(ip->type != T_DIR){
    80003318:	04499783          	lh	a5,68(s3)
    8000331c:	f98793e3          	bne	a5,s8,800032a2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003320:	000b0563          	beqz	s6,8000332a <namex+0xe6>
    80003324:	0004c783          	lbu	a5,0(s1)
    80003328:	d3cd                	beqz	a5,800032ca <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000332a:	865e                	mv	a2,s7
    8000332c:	85d6                	mv	a1,s5
    8000332e:	854e                	mv	a0,s3
    80003330:	00000097          	auipc	ra,0x0
    80003334:	e64080e7          	jalr	-412(ra) # 80003194 <dirlookup>
    80003338:	8a2a                	mv	s4,a0
    8000333a:	dd51                	beqz	a0,800032d6 <namex+0x92>
    iunlockput(ip);
    8000333c:	854e                	mv	a0,s3
    8000333e:	00000097          	auipc	ra,0x0
    80003342:	bd4080e7          	jalr	-1068(ra) # 80002f12 <iunlockput>
    ip = next;
    80003346:	89d2                	mv	s3,s4
  while(*path == '/')
    80003348:	0004c783          	lbu	a5,0(s1)
    8000334c:	05279763          	bne	a5,s2,8000339a <namex+0x156>
    path++;
    80003350:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003352:	0004c783          	lbu	a5,0(s1)
    80003356:	ff278de3          	beq	a5,s2,80003350 <namex+0x10c>
  if(*path == 0)
    8000335a:	c79d                	beqz	a5,80003388 <namex+0x144>
    path++;
    8000335c:	85a6                	mv	a1,s1
  len = path - s;
    8000335e:	8a5e                	mv	s4,s7
    80003360:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003362:	01278963          	beq	a5,s2,80003374 <namex+0x130>
    80003366:	dfbd                	beqz	a5,800032e4 <namex+0xa0>
    path++;
    80003368:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000336a:	0004c783          	lbu	a5,0(s1)
    8000336e:	ff279ce3          	bne	a5,s2,80003366 <namex+0x122>
    80003372:	bf8d                	j	800032e4 <namex+0xa0>
    memmove(name, s, len);
    80003374:	2601                	sext.w	a2,a2
    80003376:	8556                	mv	a0,s5
    80003378:	ffffd097          	auipc	ra,0xffffd
    8000337c:	f9c080e7          	jalr	-100(ra) # 80000314 <memmove>
    name[len] = 0;
    80003380:	9a56                	add	s4,s4,s5
    80003382:	000a0023          	sb	zero,0(s4)
    80003386:	bf9d                	j	800032fc <namex+0xb8>
  if(nameiparent){
    80003388:	f20b03e3          	beqz	s6,800032ae <namex+0x6a>
    iput(ip);
    8000338c:	854e                	mv	a0,s3
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	adc080e7          	jalr	-1316(ra) # 80002e6a <iput>
    return 0;
    80003396:	4981                	li	s3,0
    80003398:	bf19                	j	800032ae <namex+0x6a>
  if(*path == 0)
    8000339a:	d7fd                	beqz	a5,80003388 <namex+0x144>
  while(*path != '/' && *path != 0)
    8000339c:	0004c783          	lbu	a5,0(s1)
    800033a0:	85a6                	mv	a1,s1
    800033a2:	b7d1                	j	80003366 <namex+0x122>

00000000800033a4 <dirlink>:
{
    800033a4:	7139                	addi	sp,sp,-64
    800033a6:	fc06                	sd	ra,56(sp)
    800033a8:	f822                	sd	s0,48(sp)
    800033aa:	f426                	sd	s1,40(sp)
    800033ac:	f04a                	sd	s2,32(sp)
    800033ae:	ec4e                	sd	s3,24(sp)
    800033b0:	e852                	sd	s4,16(sp)
    800033b2:	0080                	addi	s0,sp,64
    800033b4:	892a                	mv	s2,a0
    800033b6:	8a2e                	mv	s4,a1
    800033b8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800033ba:	4601                	li	a2,0
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	dd8080e7          	jalr	-552(ra) # 80003194 <dirlookup>
    800033c4:	e93d                	bnez	a0,8000343a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800033c6:	04c92483          	lw	s1,76(s2)
    800033ca:	c49d                	beqz	s1,800033f8 <dirlink+0x54>
    800033cc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800033ce:	4741                	li	a4,16
    800033d0:	86a6                	mv	a3,s1
    800033d2:	fc040613          	addi	a2,s0,-64
    800033d6:	4581                	li	a1,0
    800033d8:	854a                	mv	a0,s2
    800033da:	00000097          	auipc	ra,0x0
    800033de:	b8a080e7          	jalr	-1142(ra) # 80002f64 <readi>
    800033e2:	47c1                	li	a5,16
    800033e4:	06f51163          	bne	a0,a5,80003446 <dirlink+0xa2>
    if(de.inum == 0)
    800033e8:	fc045783          	lhu	a5,-64(s0)
    800033ec:	c791                	beqz	a5,800033f8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800033ee:	24c1                	addiw	s1,s1,16
    800033f0:	04c92783          	lw	a5,76(s2)
    800033f4:	fcf4ede3          	bltu	s1,a5,800033ce <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800033f8:	4639                	li	a2,14
    800033fa:	85d2                	mv	a1,s4
    800033fc:	fc240513          	addi	a0,s0,-62
    80003400:	ffffd097          	auipc	ra,0xffffd
    80003404:	fc8080e7          	jalr	-56(ra) # 800003c8 <strncpy>
  de.inum = inum;
    80003408:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000340c:	4741                	li	a4,16
    8000340e:	86a6                	mv	a3,s1
    80003410:	fc040613          	addi	a2,s0,-64
    80003414:	4581                	li	a1,0
    80003416:	854a                	mv	a0,s2
    80003418:	00000097          	auipc	ra,0x0
    8000341c:	c44080e7          	jalr	-956(ra) # 8000305c <writei>
    80003420:	872a                	mv	a4,a0
    80003422:	47c1                	li	a5,16
  return 0;
    80003424:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003426:	02f71863          	bne	a4,a5,80003456 <dirlink+0xb2>
}
    8000342a:	70e2                	ld	ra,56(sp)
    8000342c:	7442                	ld	s0,48(sp)
    8000342e:	74a2                	ld	s1,40(sp)
    80003430:	7902                	ld	s2,32(sp)
    80003432:	69e2                	ld	s3,24(sp)
    80003434:	6a42                	ld	s4,16(sp)
    80003436:	6121                	addi	sp,sp,64
    80003438:	8082                	ret
    iput(ip);
    8000343a:	00000097          	auipc	ra,0x0
    8000343e:	a30080e7          	jalr	-1488(ra) # 80002e6a <iput>
    return -1;
    80003442:	557d                	li	a0,-1
    80003444:	b7dd                	j	8000342a <dirlink+0x86>
      panic("dirlink read");
    80003446:	00005517          	auipc	a0,0x5
    8000344a:	1a250513          	addi	a0,a0,418 # 800085e8 <syscalls+0x1c8>
    8000344e:	00003097          	auipc	ra,0x3
    80003452:	91a080e7          	jalr	-1766(ra) # 80005d68 <panic>
    panic("dirlink");
    80003456:	00005517          	auipc	a0,0x5
    8000345a:	2a250513          	addi	a0,a0,674 # 800086f8 <syscalls+0x2d8>
    8000345e:	00003097          	auipc	ra,0x3
    80003462:	90a080e7          	jalr	-1782(ra) # 80005d68 <panic>

0000000080003466 <namei>:

struct inode*
namei(char *path)
{
    80003466:	1101                	addi	sp,sp,-32
    80003468:	ec06                	sd	ra,24(sp)
    8000346a:	e822                	sd	s0,16(sp)
    8000346c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000346e:	fe040613          	addi	a2,s0,-32
    80003472:	4581                	li	a1,0
    80003474:	00000097          	auipc	ra,0x0
    80003478:	dd0080e7          	jalr	-560(ra) # 80003244 <namex>
}
    8000347c:	60e2                	ld	ra,24(sp)
    8000347e:	6442                	ld	s0,16(sp)
    80003480:	6105                	addi	sp,sp,32
    80003482:	8082                	ret

0000000080003484 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003484:	1141                	addi	sp,sp,-16
    80003486:	e406                	sd	ra,8(sp)
    80003488:	e022                	sd	s0,0(sp)
    8000348a:	0800                	addi	s0,sp,16
    8000348c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000348e:	4585                	li	a1,1
    80003490:	00000097          	auipc	ra,0x0
    80003494:	db4080e7          	jalr	-588(ra) # 80003244 <namex>
}
    80003498:	60a2                	ld	ra,8(sp)
    8000349a:	6402                	ld	s0,0(sp)
    8000349c:	0141                	addi	sp,sp,16
    8000349e:	8082                	ret

00000000800034a0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800034a0:	1101                	addi	sp,sp,-32
    800034a2:	ec06                	sd	ra,24(sp)
    800034a4:	e822                	sd	s0,16(sp)
    800034a6:	e426                	sd	s1,8(sp)
    800034a8:	e04a                	sd	s2,0(sp)
    800034aa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800034ac:	00236917          	auipc	s2,0x236
    800034b0:	b8c90913          	addi	s2,s2,-1140 # 80239038 <log>
    800034b4:	01892583          	lw	a1,24(s2)
    800034b8:	02892503          	lw	a0,40(s2)
    800034bc:	fffff097          	auipc	ra,0xfffff
    800034c0:	ff2080e7          	jalr	-14(ra) # 800024ae <bread>
    800034c4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800034c6:	02c92683          	lw	a3,44(s2)
    800034ca:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800034cc:	02d05763          	blez	a3,800034fa <write_head+0x5a>
    800034d0:	00236797          	auipc	a5,0x236
    800034d4:	b9878793          	addi	a5,a5,-1128 # 80239068 <log+0x30>
    800034d8:	05c50713          	addi	a4,a0,92
    800034dc:	36fd                	addiw	a3,a3,-1
    800034de:	1682                	slli	a3,a3,0x20
    800034e0:	9281                	srli	a3,a3,0x20
    800034e2:	068a                	slli	a3,a3,0x2
    800034e4:	00236617          	auipc	a2,0x236
    800034e8:	b8860613          	addi	a2,a2,-1144 # 8023906c <log+0x34>
    800034ec:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800034ee:	4390                	lw	a2,0(a5)
    800034f0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800034f2:	0791                	addi	a5,a5,4
    800034f4:	0711                	addi	a4,a4,4
    800034f6:	fed79ce3          	bne	a5,a3,800034ee <write_head+0x4e>
  }
  bwrite(buf);
    800034fa:	8526                	mv	a0,s1
    800034fc:	fffff097          	auipc	ra,0xfffff
    80003500:	0a4080e7          	jalr	164(ra) # 800025a0 <bwrite>
  brelse(buf);
    80003504:	8526                	mv	a0,s1
    80003506:	fffff097          	auipc	ra,0xfffff
    8000350a:	0d8080e7          	jalr	216(ra) # 800025de <brelse>
}
    8000350e:	60e2                	ld	ra,24(sp)
    80003510:	6442                	ld	s0,16(sp)
    80003512:	64a2                	ld	s1,8(sp)
    80003514:	6902                	ld	s2,0(sp)
    80003516:	6105                	addi	sp,sp,32
    80003518:	8082                	ret

000000008000351a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000351a:	00236797          	auipc	a5,0x236
    8000351e:	b4a7a783          	lw	a5,-1206(a5) # 80239064 <log+0x2c>
    80003522:	0af05d63          	blez	a5,800035dc <install_trans+0xc2>
{
    80003526:	7139                	addi	sp,sp,-64
    80003528:	fc06                	sd	ra,56(sp)
    8000352a:	f822                	sd	s0,48(sp)
    8000352c:	f426                	sd	s1,40(sp)
    8000352e:	f04a                	sd	s2,32(sp)
    80003530:	ec4e                	sd	s3,24(sp)
    80003532:	e852                	sd	s4,16(sp)
    80003534:	e456                	sd	s5,8(sp)
    80003536:	e05a                	sd	s6,0(sp)
    80003538:	0080                	addi	s0,sp,64
    8000353a:	8b2a                	mv	s6,a0
    8000353c:	00236a97          	auipc	s5,0x236
    80003540:	b2ca8a93          	addi	s5,s5,-1236 # 80239068 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003544:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003546:	00236997          	auipc	s3,0x236
    8000354a:	af298993          	addi	s3,s3,-1294 # 80239038 <log>
    8000354e:	a035                	j	8000357a <install_trans+0x60>
      bunpin(dbuf);
    80003550:	8526                	mv	a0,s1
    80003552:	fffff097          	auipc	ra,0xfffff
    80003556:	166080e7          	jalr	358(ra) # 800026b8 <bunpin>
    brelse(lbuf);
    8000355a:	854a                	mv	a0,s2
    8000355c:	fffff097          	auipc	ra,0xfffff
    80003560:	082080e7          	jalr	130(ra) # 800025de <brelse>
    brelse(dbuf);
    80003564:	8526                	mv	a0,s1
    80003566:	fffff097          	auipc	ra,0xfffff
    8000356a:	078080e7          	jalr	120(ra) # 800025de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000356e:	2a05                	addiw	s4,s4,1
    80003570:	0a91                	addi	s5,s5,4
    80003572:	02c9a783          	lw	a5,44(s3)
    80003576:	04fa5963          	bge	s4,a5,800035c8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000357a:	0189a583          	lw	a1,24(s3)
    8000357e:	014585bb          	addw	a1,a1,s4
    80003582:	2585                	addiw	a1,a1,1
    80003584:	0289a503          	lw	a0,40(s3)
    80003588:	fffff097          	auipc	ra,0xfffff
    8000358c:	f26080e7          	jalr	-218(ra) # 800024ae <bread>
    80003590:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003592:	000aa583          	lw	a1,0(s5)
    80003596:	0289a503          	lw	a0,40(s3)
    8000359a:	fffff097          	auipc	ra,0xfffff
    8000359e:	f14080e7          	jalr	-236(ra) # 800024ae <bread>
    800035a2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800035a4:	40000613          	li	a2,1024
    800035a8:	05890593          	addi	a1,s2,88
    800035ac:	05850513          	addi	a0,a0,88
    800035b0:	ffffd097          	auipc	ra,0xffffd
    800035b4:	d64080e7          	jalr	-668(ra) # 80000314 <memmove>
    bwrite(dbuf);  // write dst to disk
    800035b8:	8526                	mv	a0,s1
    800035ba:	fffff097          	auipc	ra,0xfffff
    800035be:	fe6080e7          	jalr	-26(ra) # 800025a0 <bwrite>
    if(recovering == 0)
    800035c2:	f80b1ce3          	bnez	s6,8000355a <install_trans+0x40>
    800035c6:	b769                	j	80003550 <install_trans+0x36>
}
    800035c8:	70e2                	ld	ra,56(sp)
    800035ca:	7442                	ld	s0,48(sp)
    800035cc:	74a2                	ld	s1,40(sp)
    800035ce:	7902                	ld	s2,32(sp)
    800035d0:	69e2                	ld	s3,24(sp)
    800035d2:	6a42                	ld	s4,16(sp)
    800035d4:	6aa2                	ld	s5,8(sp)
    800035d6:	6b02                	ld	s6,0(sp)
    800035d8:	6121                	addi	sp,sp,64
    800035da:	8082                	ret
    800035dc:	8082                	ret

00000000800035de <initlog>:
{
    800035de:	7179                	addi	sp,sp,-48
    800035e0:	f406                	sd	ra,40(sp)
    800035e2:	f022                	sd	s0,32(sp)
    800035e4:	ec26                	sd	s1,24(sp)
    800035e6:	e84a                	sd	s2,16(sp)
    800035e8:	e44e                	sd	s3,8(sp)
    800035ea:	1800                	addi	s0,sp,48
    800035ec:	892a                	mv	s2,a0
    800035ee:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800035f0:	00236497          	auipc	s1,0x236
    800035f4:	a4848493          	addi	s1,s1,-1464 # 80239038 <log>
    800035f8:	00005597          	auipc	a1,0x5
    800035fc:	00058593          	mv	a1,a1
    80003600:	8526                	mv	a0,s1
    80003602:	00003097          	auipc	ra,0x3
    80003606:	c20080e7          	jalr	-992(ra) # 80006222 <initlock>
  log.start = sb->logstart;
    8000360a:	0149a583          	lw	a1,20(s3)
    8000360e:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003610:	0109a783          	lw	a5,16(s3)
    80003614:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003616:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000361a:	854a                	mv	a0,s2
    8000361c:	fffff097          	auipc	ra,0xfffff
    80003620:	e92080e7          	jalr	-366(ra) # 800024ae <bread>
  log.lh.n = lh->n;
    80003624:	4d3c                	lw	a5,88(a0)
    80003626:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003628:	02f05563          	blez	a5,80003652 <initlog+0x74>
    8000362c:	05c50713          	addi	a4,a0,92
    80003630:	00236697          	auipc	a3,0x236
    80003634:	a3868693          	addi	a3,a3,-1480 # 80239068 <log+0x30>
    80003638:	37fd                	addiw	a5,a5,-1
    8000363a:	1782                	slli	a5,a5,0x20
    8000363c:	9381                	srli	a5,a5,0x20
    8000363e:	078a                	slli	a5,a5,0x2
    80003640:	06050613          	addi	a2,a0,96
    80003644:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003646:	4310                	lw	a2,0(a4)
    80003648:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000364a:	0711                	addi	a4,a4,4
    8000364c:	0691                	addi	a3,a3,4
    8000364e:	fef71ce3          	bne	a4,a5,80003646 <initlog+0x68>
  brelse(buf);
    80003652:	fffff097          	auipc	ra,0xfffff
    80003656:	f8c080e7          	jalr	-116(ra) # 800025de <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000365a:	4505                	li	a0,1
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	ebe080e7          	jalr	-322(ra) # 8000351a <install_trans>
  log.lh.n = 0;
    80003664:	00236797          	auipc	a5,0x236
    80003668:	a007a023          	sw	zero,-1536(a5) # 80239064 <log+0x2c>
  write_head(); // clear the log
    8000366c:	00000097          	auipc	ra,0x0
    80003670:	e34080e7          	jalr	-460(ra) # 800034a0 <write_head>
}
    80003674:	70a2                	ld	ra,40(sp)
    80003676:	7402                	ld	s0,32(sp)
    80003678:	64e2                	ld	s1,24(sp)
    8000367a:	6942                	ld	s2,16(sp)
    8000367c:	69a2                	ld	s3,8(sp)
    8000367e:	6145                	addi	sp,sp,48
    80003680:	8082                	ret

0000000080003682 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003682:	1101                	addi	sp,sp,-32
    80003684:	ec06                	sd	ra,24(sp)
    80003686:	e822                	sd	s0,16(sp)
    80003688:	e426                	sd	s1,8(sp)
    8000368a:	e04a                	sd	s2,0(sp)
    8000368c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000368e:	00236517          	auipc	a0,0x236
    80003692:	9aa50513          	addi	a0,a0,-1622 # 80239038 <log>
    80003696:	00003097          	auipc	ra,0x3
    8000369a:	c1c080e7          	jalr	-996(ra) # 800062b2 <acquire>
  while(1){
    if(log.committing){
    8000369e:	00236497          	auipc	s1,0x236
    800036a2:	99a48493          	addi	s1,s1,-1638 # 80239038 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800036a6:	4979                	li	s2,30
    800036a8:	a039                	j	800036b6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800036aa:	85a6                	mv	a1,s1
    800036ac:	8526                	mv	a0,s1
    800036ae:	ffffe097          	auipc	ra,0xffffe
    800036b2:	fda080e7          	jalr	-38(ra) # 80001688 <sleep>
    if(log.committing){
    800036b6:	50dc                	lw	a5,36(s1)
    800036b8:	fbed                	bnez	a5,800036aa <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800036ba:	509c                	lw	a5,32(s1)
    800036bc:	0017871b          	addiw	a4,a5,1
    800036c0:	0007069b          	sext.w	a3,a4
    800036c4:	0027179b          	slliw	a5,a4,0x2
    800036c8:	9fb9                	addw	a5,a5,a4
    800036ca:	0017979b          	slliw	a5,a5,0x1
    800036ce:	54d8                	lw	a4,44(s1)
    800036d0:	9fb9                	addw	a5,a5,a4
    800036d2:	00f95963          	bge	s2,a5,800036e4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800036d6:	85a6                	mv	a1,s1
    800036d8:	8526                	mv	a0,s1
    800036da:	ffffe097          	auipc	ra,0xffffe
    800036de:	fae080e7          	jalr	-82(ra) # 80001688 <sleep>
    800036e2:	bfd1                	j	800036b6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800036e4:	00236517          	auipc	a0,0x236
    800036e8:	95450513          	addi	a0,a0,-1708 # 80239038 <log>
    800036ec:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800036ee:	00003097          	auipc	ra,0x3
    800036f2:	c78080e7          	jalr	-904(ra) # 80006366 <release>
      break;
    }
  }
}
    800036f6:	60e2                	ld	ra,24(sp)
    800036f8:	6442                	ld	s0,16(sp)
    800036fa:	64a2                	ld	s1,8(sp)
    800036fc:	6902                	ld	s2,0(sp)
    800036fe:	6105                	addi	sp,sp,32
    80003700:	8082                	ret

0000000080003702 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003702:	7139                	addi	sp,sp,-64
    80003704:	fc06                	sd	ra,56(sp)
    80003706:	f822                	sd	s0,48(sp)
    80003708:	f426                	sd	s1,40(sp)
    8000370a:	f04a                	sd	s2,32(sp)
    8000370c:	ec4e                	sd	s3,24(sp)
    8000370e:	e852                	sd	s4,16(sp)
    80003710:	e456                	sd	s5,8(sp)
    80003712:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003714:	00236497          	auipc	s1,0x236
    80003718:	92448493          	addi	s1,s1,-1756 # 80239038 <log>
    8000371c:	8526                	mv	a0,s1
    8000371e:	00003097          	auipc	ra,0x3
    80003722:	b94080e7          	jalr	-1132(ra) # 800062b2 <acquire>
  log.outstanding -= 1;
    80003726:	509c                	lw	a5,32(s1)
    80003728:	37fd                	addiw	a5,a5,-1
    8000372a:	0007891b          	sext.w	s2,a5
    8000372e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003730:	50dc                	lw	a5,36(s1)
    80003732:	efb9                	bnez	a5,80003790 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    80003734:	06091663          	bnez	s2,800037a0 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80003738:	00236497          	auipc	s1,0x236
    8000373c:	90048493          	addi	s1,s1,-1792 # 80239038 <log>
    80003740:	4785                	li	a5,1
    80003742:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003744:	8526                	mv	a0,s1
    80003746:	00003097          	auipc	ra,0x3
    8000374a:	c20080e7          	jalr	-992(ra) # 80006366 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000374e:	54dc                	lw	a5,44(s1)
    80003750:	06f04763          	bgtz	a5,800037be <end_op+0xbc>
    acquire(&log.lock);
    80003754:	00236497          	auipc	s1,0x236
    80003758:	8e448493          	addi	s1,s1,-1820 # 80239038 <log>
    8000375c:	8526                	mv	a0,s1
    8000375e:	00003097          	auipc	ra,0x3
    80003762:	b54080e7          	jalr	-1196(ra) # 800062b2 <acquire>
    log.committing = 0;
    80003766:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000376a:	8526                	mv	a0,s1
    8000376c:	ffffe097          	auipc	ra,0xffffe
    80003770:	0a8080e7          	jalr	168(ra) # 80001814 <wakeup>
    release(&log.lock);
    80003774:	8526                	mv	a0,s1
    80003776:	00003097          	auipc	ra,0x3
    8000377a:	bf0080e7          	jalr	-1040(ra) # 80006366 <release>
}
    8000377e:	70e2                	ld	ra,56(sp)
    80003780:	7442                	ld	s0,48(sp)
    80003782:	74a2                	ld	s1,40(sp)
    80003784:	7902                	ld	s2,32(sp)
    80003786:	69e2                	ld	s3,24(sp)
    80003788:	6a42                	ld	s4,16(sp)
    8000378a:	6aa2                	ld	s5,8(sp)
    8000378c:	6121                	addi	sp,sp,64
    8000378e:	8082                	ret
    panic("log.committing");
    80003790:	00005517          	auipc	a0,0x5
    80003794:	e7050513          	addi	a0,a0,-400 # 80008600 <syscalls+0x1e0>
    80003798:	00002097          	auipc	ra,0x2
    8000379c:	5d0080e7          	jalr	1488(ra) # 80005d68 <panic>
    wakeup(&log);
    800037a0:	00236497          	auipc	s1,0x236
    800037a4:	89848493          	addi	s1,s1,-1896 # 80239038 <log>
    800037a8:	8526                	mv	a0,s1
    800037aa:	ffffe097          	auipc	ra,0xffffe
    800037ae:	06a080e7          	jalr	106(ra) # 80001814 <wakeup>
  release(&log.lock);
    800037b2:	8526                	mv	a0,s1
    800037b4:	00003097          	auipc	ra,0x3
    800037b8:	bb2080e7          	jalr	-1102(ra) # 80006366 <release>
  if(do_commit){
    800037bc:	b7c9                	j	8000377e <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800037be:	00236a97          	auipc	s5,0x236
    800037c2:	8aaa8a93          	addi	s5,s5,-1878 # 80239068 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800037c6:	00236a17          	auipc	s4,0x236
    800037ca:	872a0a13          	addi	s4,s4,-1934 # 80239038 <log>
    800037ce:	018a2583          	lw	a1,24(s4)
    800037d2:	012585bb          	addw	a1,a1,s2
    800037d6:	2585                	addiw	a1,a1,1
    800037d8:	028a2503          	lw	a0,40(s4)
    800037dc:	fffff097          	auipc	ra,0xfffff
    800037e0:	cd2080e7          	jalr	-814(ra) # 800024ae <bread>
    800037e4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800037e6:	000aa583          	lw	a1,0(s5)
    800037ea:	028a2503          	lw	a0,40(s4)
    800037ee:	fffff097          	auipc	ra,0xfffff
    800037f2:	cc0080e7          	jalr	-832(ra) # 800024ae <bread>
    800037f6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800037f8:	40000613          	li	a2,1024
    800037fc:	05850593          	addi	a1,a0,88
    80003800:	05848513          	addi	a0,s1,88
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	b10080e7          	jalr	-1264(ra) # 80000314 <memmove>
    bwrite(to);  // write the log
    8000380c:	8526                	mv	a0,s1
    8000380e:	fffff097          	auipc	ra,0xfffff
    80003812:	d92080e7          	jalr	-622(ra) # 800025a0 <bwrite>
    brelse(from);
    80003816:	854e                	mv	a0,s3
    80003818:	fffff097          	auipc	ra,0xfffff
    8000381c:	dc6080e7          	jalr	-570(ra) # 800025de <brelse>
    brelse(to);
    80003820:	8526                	mv	a0,s1
    80003822:	fffff097          	auipc	ra,0xfffff
    80003826:	dbc080e7          	jalr	-580(ra) # 800025de <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000382a:	2905                	addiw	s2,s2,1
    8000382c:	0a91                	addi	s5,s5,4
    8000382e:	02ca2783          	lw	a5,44(s4)
    80003832:	f8f94ee3          	blt	s2,a5,800037ce <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003836:	00000097          	auipc	ra,0x0
    8000383a:	c6a080e7          	jalr	-918(ra) # 800034a0 <write_head>
    install_trans(0); // Now install writes to home locations
    8000383e:	4501                	li	a0,0
    80003840:	00000097          	auipc	ra,0x0
    80003844:	cda080e7          	jalr	-806(ra) # 8000351a <install_trans>
    log.lh.n = 0;
    80003848:	00236797          	auipc	a5,0x236
    8000384c:	8007ae23          	sw	zero,-2020(a5) # 80239064 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003850:	00000097          	auipc	ra,0x0
    80003854:	c50080e7          	jalr	-944(ra) # 800034a0 <write_head>
    80003858:	bdf5                	j	80003754 <end_op+0x52>

000000008000385a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000385a:	1101                	addi	sp,sp,-32
    8000385c:	ec06                	sd	ra,24(sp)
    8000385e:	e822                	sd	s0,16(sp)
    80003860:	e426                	sd	s1,8(sp)
    80003862:	e04a                	sd	s2,0(sp)
    80003864:	1000                	addi	s0,sp,32
    80003866:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003868:	00235917          	auipc	s2,0x235
    8000386c:	7d090913          	addi	s2,s2,2000 # 80239038 <log>
    80003870:	854a                	mv	a0,s2
    80003872:	00003097          	auipc	ra,0x3
    80003876:	a40080e7          	jalr	-1472(ra) # 800062b2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000387a:	02c92603          	lw	a2,44(s2)
    8000387e:	47f5                	li	a5,29
    80003880:	06c7c563          	blt	a5,a2,800038ea <log_write+0x90>
    80003884:	00235797          	auipc	a5,0x235
    80003888:	7d07a783          	lw	a5,2000(a5) # 80239054 <log+0x1c>
    8000388c:	37fd                	addiw	a5,a5,-1
    8000388e:	04f65e63          	bge	a2,a5,800038ea <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003892:	00235797          	auipc	a5,0x235
    80003896:	7c67a783          	lw	a5,1990(a5) # 80239058 <log+0x20>
    8000389a:	06f05063          	blez	a5,800038fa <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000389e:	4781                	li	a5,0
    800038a0:	06c05563          	blez	a2,8000390a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800038a4:	44cc                	lw	a1,12(s1)
    800038a6:	00235717          	auipc	a4,0x235
    800038aa:	7c270713          	addi	a4,a4,1986 # 80239068 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800038ae:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800038b0:	4314                	lw	a3,0(a4)
    800038b2:	04b68c63          	beq	a3,a1,8000390a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800038b6:	2785                	addiw	a5,a5,1
    800038b8:	0711                	addi	a4,a4,4
    800038ba:	fef61be3          	bne	a2,a5,800038b0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800038be:	0621                	addi	a2,a2,8
    800038c0:	060a                	slli	a2,a2,0x2
    800038c2:	00235797          	auipc	a5,0x235
    800038c6:	77678793          	addi	a5,a5,1910 # 80239038 <log>
    800038ca:	963e                	add	a2,a2,a5
    800038cc:	44dc                	lw	a5,12(s1)
    800038ce:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800038d0:	8526                	mv	a0,s1
    800038d2:	fffff097          	auipc	ra,0xfffff
    800038d6:	daa080e7          	jalr	-598(ra) # 8000267c <bpin>
    log.lh.n++;
    800038da:	00235717          	auipc	a4,0x235
    800038de:	75e70713          	addi	a4,a4,1886 # 80239038 <log>
    800038e2:	575c                	lw	a5,44(a4)
    800038e4:	2785                	addiw	a5,a5,1
    800038e6:	d75c                	sw	a5,44(a4)
    800038e8:	a835                	j	80003924 <log_write+0xca>
    panic("too big a transaction");
    800038ea:	00005517          	auipc	a0,0x5
    800038ee:	d2650513          	addi	a0,a0,-730 # 80008610 <syscalls+0x1f0>
    800038f2:	00002097          	auipc	ra,0x2
    800038f6:	476080e7          	jalr	1142(ra) # 80005d68 <panic>
    panic("log_write outside of trans");
    800038fa:	00005517          	auipc	a0,0x5
    800038fe:	d2e50513          	addi	a0,a0,-722 # 80008628 <syscalls+0x208>
    80003902:	00002097          	auipc	ra,0x2
    80003906:	466080e7          	jalr	1126(ra) # 80005d68 <panic>
  log.lh.block[i] = b->blockno;
    8000390a:	00878713          	addi	a4,a5,8
    8000390e:	00271693          	slli	a3,a4,0x2
    80003912:	00235717          	auipc	a4,0x235
    80003916:	72670713          	addi	a4,a4,1830 # 80239038 <log>
    8000391a:	9736                	add	a4,a4,a3
    8000391c:	44d4                	lw	a3,12(s1)
    8000391e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003920:	faf608e3          	beq	a2,a5,800038d0 <log_write+0x76>
  }
  release(&log.lock);
    80003924:	00235517          	auipc	a0,0x235
    80003928:	71450513          	addi	a0,a0,1812 # 80239038 <log>
    8000392c:	00003097          	auipc	ra,0x3
    80003930:	a3a080e7          	jalr	-1478(ra) # 80006366 <release>
}
    80003934:	60e2                	ld	ra,24(sp)
    80003936:	6442                	ld	s0,16(sp)
    80003938:	64a2                	ld	s1,8(sp)
    8000393a:	6902                	ld	s2,0(sp)
    8000393c:	6105                	addi	sp,sp,32
    8000393e:	8082                	ret

0000000080003940 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003940:	1101                	addi	sp,sp,-32
    80003942:	ec06                	sd	ra,24(sp)
    80003944:	e822                	sd	s0,16(sp)
    80003946:	e426                	sd	s1,8(sp)
    80003948:	e04a                	sd	s2,0(sp)
    8000394a:	1000                	addi	s0,sp,32
    8000394c:	84aa                	mv	s1,a0
    8000394e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003950:	00005597          	auipc	a1,0x5
    80003954:	cf858593          	addi	a1,a1,-776 # 80008648 <syscalls+0x228>
    80003958:	0521                	addi	a0,a0,8
    8000395a:	00003097          	auipc	ra,0x3
    8000395e:	8c8080e7          	jalr	-1848(ra) # 80006222 <initlock>
  lk->name = name;
    80003962:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003966:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000396a:	0204a423          	sw	zero,40(s1)
}
    8000396e:	60e2                	ld	ra,24(sp)
    80003970:	6442                	ld	s0,16(sp)
    80003972:	64a2                	ld	s1,8(sp)
    80003974:	6902                	ld	s2,0(sp)
    80003976:	6105                	addi	sp,sp,32
    80003978:	8082                	ret

000000008000397a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000397a:	1101                	addi	sp,sp,-32
    8000397c:	ec06                	sd	ra,24(sp)
    8000397e:	e822                	sd	s0,16(sp)
    80003980:	e426                	sd	s1,8(sp)
    80003982:	e04a                	sd	s2,0(sp)
    80003984:	1000                	addi	s0,sp,32
    80003986:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003988:	00850913          	addi	s2,a0,8
    8000398c:	854a                	mv	a0,s2
    8000398e:	00003097          	auipc	ra,0x3
    80003992:	924080e7          	jalr	-1756(ra) # 800062b2 <acquire>
  while (lk->locked) {
    80003996:	409c                	lw	a5,0(s1)
    80003998:	cb89                	beqz	a5,800039aa <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000399a:	85ca                	mv	a1,s2
    8000399c:	8526                	mv	a0,s1
    8000399e:	ffffe097          	auipc	ra,0xffffe
    800039a2:	cea080e7          	jalr	-790(ra) # 80001688 <sleep>
  while (lk->locked) {
    800039a6:	409c                	lw	a5,0(s1)
    800039a8:	fbed                	bnez	a5,8000399a <acquiresleep+0x20>
  }
  lk->locked = 1;
    800039aa:	4785                	li	a5,1
    800039ac:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800039ae:	ffffd097          	auipc	ra,0xffffd
    800039b2:	61e080e7          	jalr	1566(ra) # 80000fcc <myproc>
    800039b6:	591c                	lw	a5,48(a0)
    800039b8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800039ba:	854a                	mv	a0,s2
    800039bc:	00003097          	auipc	ra,0x3
    800039c0:	9aa080e7          	jalr	-1622(ra) # 80006366 <release>
}
    800039c4:	60e2                	ld	ra,24(sp)
    800039c6:	6442                	ld	s0,16(sp)
    800039c8:	64a2                	ld	s1,8(sp)
    800039ca:	6902                	ld	s2,0(sp)
    800039cc:	6105                	addi	sp,sp,32
    800039ce:	8082                	ret

00000000800039d0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800039d0:	1101                	addi	sp,sp,-32
    800039d2:	ec06                	sd	ra,24(sp)
    800039d4:	e822                	sd	s0,16(sp)
    800039d6:	e426                	sd	s1,8(sp)
    800039d8:	e04a                	sd	s2,0(sp)
    800039da:	1000                	addi	s0,sp,32
    800039dc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800039de:	00850913          	addi	s2,a0,8
    800039e2:	854a                	mv	a0,s2
    800039e4:	00003097          	auipc	ra,0x3
    800039e8:	8ce080e7          	jalr	-1842(ra) # 800062b2 <acquire>
  lk->locked = 0;
    800039ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800039f0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800039f4:	8526                	mv	a0,s1
    800039f6:	ffffe097          	auipc	ra,0xffffe
    800039fa:	e1e080e7          	jalr	-482(ra) # 80001814 <wakeup>
  release(&lk->lk);
    800039fe:	854a                	mv	a0,s2
    80003a00:	00003097          	auipc	ra,0x3
    80003a04:	966080e7          	jalr	-1690(ra) # 80006366 <release>
}
    80003a08:	60e2                	ld	ra,24(sp)
    80003a0a:	6442                	ld	s0,16(sp)
    80003a0c:	64a2                	ld	s1,8(sp)
    80003a0e:	6902                	ld	s2,0(sp)
    80003a10:	6105                	addi	sp,sp,32
    80003a12:	8082                	ret

0000000080003a14 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003a14:	7179                	addi	sp,sp,-48
    80003a16:	f406                	sd	ra,40(sp)
    80003a18:	f022                	sd	s0,32(sp)
    80003a1a:	ec26                	sd	s1,24(sp)
    80003a1c:	e84a                	sd	s2,16(sp)
    80003a1e:	e44e                	sd	s3,8(sp)
    80003a20:	1800                	addi	s0,sp,48
    80003a22:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003a24:	00850913          	addi	s2,a0,8
    80003a28:	854a                	mv	a0,s2
    80003a2a:	00003097          	auipc	ra,0x3
    80003a2e:	888080e7          	jalr	-1912(ra) # 800062b2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003a32:	409c                	lw	a5,0(s1)
    80003a34:	ef99                	bnez	a5,80003a52 <holdingsleep+0x3e>
    80003a36:	4481                	li	s1,0
  release(&lk->lk);
    80003a38:	854a                	mv	a0,s2
    80003a3a:	00003097          	auipc	ra,0x3
    80003a3e:	92c080e7          	jalr	-1748(ra) # 80006366 <release>
  return r;
}
    80003a42:	8526                	mv	a0,s1
    80003a44:	70a2                	ld	ra,40(sp)
    80003a46:	7402                	ld	s0,32(sp)
    80003a48:	64e2                	ld	s1,24(sp)
    80003a4a:	6942                	ld	s2,16(sp)
    80003a4c:	69a2                	ld	s3,8(sp)
    80003a4e:	6145                	addi	sp,sp,48
    80003a50:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003a52:	0284a983          	lw	s3,40(s1)
    80003a56:	ffffd097          	auipc	ra,0xffffd
    80003a5a:	576080e7          	jalr	1398(ra) # 80000fcc <myproc>
    80003a5e:	5904                	lw	s1,48(a0)
    80003a60:	413484b3          	sub	s1,s1,s3
    80003a64:	0014b493          	seqz	s1,s1
    80003a68:	bfc1                	j	80003a38 <holdingsleep+0x24>

0000000080003a6a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003a6a:	1141                	addi	sp,sp,-16
    80003a6c:	e406                	sd	ra,8(sp)
    80003a6e:	e022                	sd	s0,0(sp)
    80003a70:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003a72:	00005597          	auipc	a1,0x5
    80003a76:	be658593          	addi	a1,a1,-1050 # 80008658 <syscalls+0x238>
    80003a7a:	00235517          	auipc	a0,0x235
    80003a7e:	70650513          	addi	a0,a0,1798 # 80239180 <ftable>
    80003a82:	00002097          	auipc	ra,0x2
    80003a86:	7a0080e7          	jalr	1952(ra) # 80006222 <initlock>
}
    80003a8a:	60a2                	ld	ra,8(sp)
    80003a8c:	6402                	ld	s0,0(sp)
    80003a8e:	0141                	addi	sp,sp,16
    80003a90:	8082                	ret

0000000080003a92 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003a92:	1101                	addi	sp,sp,-32
    80003a94:	ec06                	sd	ra,24(sp)
    80003a96:	e822                	sd	s0,16(sp)
    80003a98:	e426                	sd	s1,8(sp)
    80003a9a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003a9c:	00235517          	auipc	a0,0x235
    80003aa0:	6e450513          	addi	a0,a0,1764 # 80239180 <ftable>
    80003aa4:	00003097          	auipc	ra,0x3
    80003aa8:	80e080e7          	jalr	-2034(ra) # 800062b2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003aac:	00235497          	auipc	s1,0x235
    80003ab0:	6ec48493          	addi	s1,s1,1772 # 80239198 <ftable+0x18>
    80003ab4:	00236717          	auipc	a4,0x236
    80003ab8:	68470713          	addi	a4,a4,1668 # 8023a138 <ftable+0xfb8>
    if(f->ref == 0){
    80003abc:	40dc                	lw	a5,4(s1)
    80003abe:	cf99                	beqz	a5,80003adc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003ac0:	02848493          	addi	s1,s1,40
    80003ac4:	fee49ce3          	bne	s1,a4,80003abc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003ac8:	00235517          	auipc	a0,0x235
    80003acc:	6b850513          	addi	a0,a0,1720 # 80239180 <ftable>
    80003ad0:	00003097          	auipc	ra,0x3
    80003ad4:	896080e7          	jalr	-1898(ra) # 80006366 <release>
  return 0;
    80003ad8:	4481                	li	s1,0
    80003ada:	a819                	j	80003af0 <filealloc+0x5e>
      f->ref = 1;
    80003adc:	4785                	li	a5,1
    80003ade:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003ae0:	00235517          	auipc	a0,0x235
    80003ae4:	6a050513          	addi	a0,a0,1696 # 80239180 <ftable>
    80003ae8:	00003097          	auipc	ra,0x3
    80003aec:	87e080e7          	jalr	-1922(ra) # 80006366 <release>
}
    80003af0:	8526                	mv	a0,s1
    80003af2:	60e2                	ld	ra,24(sp)
    80003af4:	6442                	ld	s0,16(sp)
    80003af6:	64a2                	ld	s1,8(sp)
    80003af8:	6105                	addi	sp,sp,32
    80003afa:	8082                	ret

0000000080003afc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003afc:	1101                	addi	sp,sp,-32
    80003afe:	ec06                	sd	ra,24(sp)
    80003b00:	e822                	sd	s0,16(sp)
    80003b02:	e426                	sd	s1,8(sp)
    80003b04:	1000                	addi	s0,sp,32
    80003b06:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003b08:	00235517          	auipc	a0,0x235
    80003b0c:	67850513          	addi	a0,a0,1656 # 80239180 <ftable>
    80003b10:	00002097          	auipc	ra,0x2
    80003b14:	7a2080e7          	jalr	1954(ra) # 800062b2 <acquire>
  if(f->ref < 1)
    80003b18:	40dc                	lw	a5,4(s1)
    80003b1a:	02f05263          	blez	a5,80003b3e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003b1e:	2785                	addiw	a5,a5,1
    80003b20:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003b22:	00235517          	auipc	a0,0x235
    80003b26:	65e50513          	addi	a0,a0,1630 # 80239180 <ftable>
    80003b2a:	00003097          	auipc	ra,0x3
    80003b2e:	83c080e7          	jalr	-1988(ra) # 80006366 <release>
  return f;
}
    80003b32:	8526                	mv	a0,s1
    80003b34:	60e2                	ld	ra,24(sp)
    80003b36:	6442                	ld	s0,16(sp)
    80003b38:	64a2                	ld	s1,8(sp)
    80003b3a:	6105                	addi	sp,sp,32
    80003b3c:	8082                	ret
    panic("filedup");
    80003b3e:	00005517          	auipc	a0,0x5
    80003b42:	b2250513          	addi	a0,a0,-1246 # 80008660 <syscalls+0x240>
    80003b46:	00002097          	auipc	ra,0x2
    80003b4a:	222080e7          	jalr	546(ra) # 80005d68 <panic>

0000000080003b4e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003b4e:	7139                	addi	sp,sp,-64
    80003b50:	fc06                	sd	ra,56(sp)
    80003b52:	f822                	sd	s0,48(sp)
    80003b54:	f426                	sd	s1,40(sp)
    80003b56:	f04a                	sd	s2,32(sp)
    80003b58:	ec4e                	sd	s3,24(sp)
    80003b5a:	e852                	sd	s4,16(sp)
    80003b5c:	e456                	sd	s5,8(sp)
    80003b5e:	0080                	addi	s0,sp,64
    80003b60:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003b62:	00235517          	auipc	a0,0x235
    80003b66:	61e50513          	addi	a0,a0,1566 # 80239180 <ftable>
    80003b6a:	00002097          	auipc	ra,0x2
    80003b6e:	748080e7          	jalr	1864(ra) # 800062b2 <acquire>
  if(f->ref < 1)
    80003b72:	40dc                	lw	a5,4(s1)
    80003b74:	06f05163          	blez	a5,80003bd6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003b78:	37fd                	addiw	a5,a5,-1
    80003b7a:	0007871b          	sext.w	a4,a5
    80003b7e:	c0dc                	sw	a5,4(s1)
    80003b80:	06e04363          	bgtz	a4,80003be6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003b84:	0004a903          	lw	s2,0(s1)
    80003b88:	0094ca83          	lbu	s5,9(s1)
    80003b8c:	0104ba03          	ld	s4,16(s1)
    80003b90:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003b94:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003b98:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003b9c:	00235517          	auipc	a0,0x235
    80003ba0:	5e450513          	addi	a0,a0,1508 # 80239180 <ftable>
    80003ba4:	00002097          	auipc	ra,0x2
    80003ba8:	7c2080e7          	jalr	1986(ra) # 80006366 <release>

  if(ff.type == FD_PIPE){
    80003bac:	4785                	li	a5,1
    80003bae:	04f90d63          	beq	s2,a5,80003c08 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003bb2:	3979                	addiw	s2,s2,-2
    80003bb4:	4785                	li	a5,1
    80003bb6:	0527e063          	bltu	a5,s2,80003bf6 <fileclose+0xa8>
    begin_op();
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	ac8080e7          	jalr	-1336(ra) # 80003682 <begin_op>
    iput(ff.ip);
    80003bc2:	854e                	mv	a0,s3
    80003bc4:	fffff097          	auipc	ra,0xfffff
    80003bc8:	2a6080e7          	jalr	678(ra) # 80002e6a <iput>
    end_op();
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	b36080e7          	jalr	-1226(ra) # 80003702 <end_op>
    80003bd4:	a00d                	j	80003bf6 <fileclose+0xa8>
    panic("fileclose");
    80003bd6:	00005517          	auipc	a0,0x5
    80003bda:	a9250513          	addi	a0,a0,-1390 # 80008668 <syscalls+0x248>
    80003bde:	00002097          	auipc	ra,0x2
    80003be2:	18a080e7          	jalr	394(ra) # 80005d68 <panic>
    release(&ftable.lock);
    80003be6:	00235517          	auipc	a0,0x235
    80003bea:	59a50513          	addi	a0,a0,1434 # 80239180 <ftable>
    80003bee:	00002097          	auipc	ra,0x2
    80003bf2:	778080e7          	jalr	1912(ra) # 80006366 <release>
  }
}
    80003bf6:	70e2                	ld	ra,56(sp)
    80003bf8:	7442                	ld	s0,48(sp)
    80003bfa:	74a2                	ld	s1,40(sp)
    80003bfc:	7902                	ld	s2,32(sp)
    80003bfe:	69e2                	ld	s3,24(sp)
    80003c00:	6a42                	ld	s4,16(sp)
    80003c02:	6aa2                	ld	s5,8(sp)
    80003c04:	6121                	addi	sp,sp,64
    80003c06:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003c08:	85d6                	mv	a1,s5
    80003c0a:	8552                	mv	a0,s4
    80003c0c:	00000097          	auipc	ra,0x0
    80003c10:	34c080e7          	jalr	844(ra) # 80003f58 <pipeclose>
    80003c14:	b7cd                	j	80003bf6 <fileclose+0xa8>

0000000080003c16 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003c16:	715d                	addi	sp,sp,-80
    80003c18:	e486                	sd	ra,72(sp)
    80003c1a:	e0a2                	sd	s0,64(sp)
    80003c1c:	fc26                	sd	s1,56(sp)
    80003c1e:	f84a                	sd	s2,48(sp)
    80003c20:	f44e                	sd	s3,40(sp)
    80003c22:	0880                	addi	s0,sp,80
    80003c24:	84aa                	mv	s1,a0
    80003c26:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003c28:	ffffd097          	auipc	ra,0xffffd
    80003c2c:	3a4080e7          	jalr	932(ra) # 80000fcc <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003c30:	409c                	lw	a5,0(s1)
    80003c32:	37f9                	addiw	a5,a5,-2
    80003c34:	4705                	li	a4,1
    80003c36:	04f76763          	bltu	a4,a5,80003c84 <filestat+0x6e>
    80003c3a:	892a                	mv	s2,a0
    ilock(f->ip);
    80003c3c:	6c88                	ld	a0,24(s1)
    80003c3e:	fffff097          	auipc	ra,0xfffff
    80003c42:	072080e7          	jalr	114(ra) # 80002cb0 <ilock>
    stati(f->ip, &st);
    80003c46:	fb840593          	addi	a1,s0,-72
    80003c4a:	6c88                	ld	a0,24(s1)
    80003c4c:	fffff097          	auipc	ra,0xfffff
    80003c50:	2ee080e7          	jalr	750(ra) # 80002f3a <stati>
    iunlock(f->ip);
    80003c54:	6c88                	ld	a0,24(s1)
    80003c56:	fffff097          	auipc	ra,0xfffff
    80003c5a:	11c080e7          	jalr	284(ra) # 80002d72 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003c5e:	46e1                	li	a3,24
    80003c60:	fb840613          	addi	a2,s0,-72
    80003c64:	85ce                	mv	a1,s3
    80003c66:	05093503          	ld	a0,80(s2)
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	fd8080e7          	jalr	-40(ra) # 80000c42 <copyout>
    80003c72:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003c76:	60a6                	ld	ra,72(sp)
    80003c78:	6406                	ld	s0,64(sp)
    80003c7a:	74e2                	ld	s1,56(sp)
    80003c7c:	7942                	ld	s2,48(sp)
    80003c7e:	79a2                	ld	s3,40(sp)
    80003c80:	6161                	addi	sp,sp,80
    80003c82:	8082                	ret
  return -1;
    80003c84:	557d                	li	a0,-1
    80003c86:	bfc5                	j	80003c76 <filestat+0x60>

0000000080003c88 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003c88:	7179                	addi	sp,sp,-48
    80003c8a:	f406                	sd	ra,40(sp)
    80003c8c:	f022                	sd	s0,32(sp)
    80003c8e:	ec26                	sd	s1,24(sp)
    80003c90:	e84a                	sd	s2,16(sp)
    80003c92:	e44e                	sd	s3,8(sp)
    80003c94:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003c96:	00854783          	lbu	a5,8(a0)
    80003c9a:	c3d5                	beqz	a5,80003d3e <fileread+0xb6>
    80003c9c:	84aa                	mv	s1,a0
    80003c9e:	89ae                	mv	s3,a1
    80003ca0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003ca2:	411c                	lw	a5,0(a0)
    80003ca4:	4705                	li	a4,1
    80003ca6:	04e78963          	beq	a5,a4,80003cf8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003caa:	470d                	li	a4,3
    80003cac:	04e78d63          	beq	a5,a4,80003d06 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003cb0:	4709                	li	a4,2
    80003cb2:	06e79e63          	bne	a5,a4,80003d2e <fileread+0xa6>
    ilock(f->ip);
    80003cb6:	6d08                	ld	a0,24(a0)
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	ff8080e7          	jalr	-8(ra) # 80002cb0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003cc0:	874a                	mv	a4,s2
    80003cc2:	5094                	lw	a3,32(s1)
    80003cc4:	864e                	mv	a2,s3
    80003cc6:	4585                	li	a1,1
    80003cc8:	6c88                	ld	a0,24(s1)
    80003cca:	fffff097          	auipc	ra,0xfffff
    80003cce:	29a080e7          	jalr	666(ra) # 80002f64 <readi>
    80003cd2:	892a                	mv	s2,a0
    80003cd4:	00a05563          	blez	a0,80003cde <fileread+0x56>
      f->off += r;
    80003cd8:	509c                	lw	a5,32(s1)
    80003cda:	9fa9                	addw	a5,a5,a0
    80003cdc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003cde:	6c88                	ld	a0,24(s1)
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	092080e7          	jalr	146(ra) # 80002d72 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003ce8:	854a                	mv	a0,s2
    80003cea:	70a2                	ld	ra,40(sp)
    80003cec:	7402                	ld	s0,32(sp)
    80003cee:	64e2                	ld	s1,24(sp)
    80003cf0:	6942                	ld	s2,16(sp)
    80003cf2:	69a2                	ld	s3,8(sp)
    80003cf4:	6145                	addi	sp,sp,48
    80003cf6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003cf8:	6908                	ld	a0,16(a0)
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	3c8080e7          	jalr	968(ra) # 800040c2 <piperead>
    80003d02:	892a                	mv	s2,a0
    80003d04:	b7d5                	j	80003ce8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003d06:	02451783          	lh	a5,36(a0)
    80003d0a:	03079693          	slli	a3,a5,0x30
    80003d0e:	92c1                	srli	a3,a3,0x30
    80003d10:	4725                	li	a4,9
    80003d12:	02d76863          	bltu	a4,a3,80003d42 <fileread+0xba>
    80003d16:	0792                	slli	a5,a5,0x4
    80003d18:	00235717          	auipc	a4,0x235
    80003d1c:	3c870713          	addi	a4,a4,968 # 802390e0 <devsw>
    80003d20:	97ba                	add	a5,a5,a4
    80003d22:	639c                	ld	a5,0(a5)
    80003d24:	c38d                	beqz	a5,80003d46 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003d26:	4505                	li	a0,1
    80003d28:	9782                	jalr	a5
    80003d2a:	892a                	mv	s2,a0
    80003d2c:	bf75                	j	80003ce8 <fileread+0x60>
    panic("fileread");
    80003d2e:	00005517          	auipc	a0,0x5
    80003d32:	94a50513          	addi	a0,a0,-1718 # 80008678 <syscalls+0x258>
    80003d36:	00002097          	auipc	ra,0x2
    80003d3a:	032080e7          	jalr	50(ra) # 80005d68 <panic>
    return -1;
    80003d3e:	597d                	li	s2,-1
    80003d40:	b765                	j	80003ce8 <fileread+0x60>
      return -1;
    80003d42:	597d                	li	s2,-1
    80003d44:	b755                	j	80003ce8 <fileread+0x60>
    80003d46:	597d                	li	s2,-1
    80003d48:	b745                	j	80003ce8 <fileread+0x60>

0000000080003d4a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003d4a:	715d                	addi	sp,sp,-80
    80003d4c:	e486                	sd	ra,72(sp)
    80003d4e:	e0a2                	sd	s0,64(sp)
    80003d50:	fc26                	sd	s1,56(sp)
    80003d52:	f84a                	sd	s2,48(sp)
    80003d54:	f44e                	sd	s3,40(sp)
    80003d56:	f052                	sd	s4,32(sp)
    80003d58:	ec56                	sd	s5,24(sp)
    80003d5a:	e85a                	sd	s6,16(sp)
    80003d5c:	e45e                	sd	s7,8(sp)
    80003d5e:	e062                	sd	s8,0(sp)
    80003d60:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003d62:	00954783          	lbu	a5,9(a0)
    80003d66:	10078663          	beqz	a5,80003e72 <filewrite+0x128>
    80003d6a:	892a                	mv	s2,a0
    80003d6c:	8aae                	mv	s5,a1
    80003d6e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003d70:	411c                	lw	a5,0(a0)
    80003d72:	4705                	li	a4,1
    80003d74:	02e78263          	beq	a5,a4,80003d98 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003d78:	470d                	li	a4,3
    80003d7a:	02e78663          	beq	a5,a4,80003da6 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003d7e:	4709                	li	a4,2
    80003d80:	0ee79163          	bne	a5,a4,80003e62 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003d84:	0ac05d63          	blez	a2,80003e3e <filewrite+0xf4>
    int i = 0;
    80003d88:	4981                	li	s3,0
    80003d8a:	6b05                	lui	s6,0x1
    80003d8c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003d90:	6b85                	lui	s7,0x1
    80003d92:	c00b8b9b          	addiw	s7,s7,-1024
    80003d96:	a861                	j	80003e2e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003d98:	6908                	ld	a0,16(a0)
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	22e080e7          	jalr	558(ra) # 80003fc8 <pipewrite>
    80003da2:	8a2a                	mv	s4,a0
    80003da4:	a045                	j	80003e44 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003da6:	02451783          	lh	a5,36(a0)
    80003daa:	03079693          	slli	a3,a5,0x30
    80003dae:	92c1                	srli	a3,a3,0x30
    80003db0:	4725                	li	a4,9
    80003db2:	0cd76263          	bltu	a4,a3,80003e76 <filewrite+0x12c>
    80003db6:	0792                	slli	a5,a5,0x4
    80003db8:	00235717          	auipc	a4,0x235
    80003dbc:	32870713          	addi	a4,a4,808 # 802390e0 <devsw>
    80003dc0:	97ba                	add	a5,a5,a4
    80003dc2:	679c                	ld	a5,8(a5)
    80003dc4:	cbdd                	beqz	a5,80003e7a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003dc6:	4505                	li	a0,1
    80003dc8:	9782                	jalr	a5
    80003dca:	8a2a                	mv	s4,a0
    80003dcc:	a8a5                	j	80003e44 <filewrite+0xfa>
    80003dce:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	8b0080e7          	jalr	-1872(ra) # 80003682 <begin_op>
      ilock(f->ip);
    80003dda:	01893503          	ld	a0,24(s2)
    80003dde:	fffff097          	auipc	ra,0xfffff
    80003de2:	ed2080e7          	jalr	-302(ra) # 80002cb0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003de6:	8762                	mv	a4,s8
    80003de8:	02092683          	lw	a3,32(s2)
    80003dec:	01598633          	add	a2,s3,s5
    80003df0:	4585                	li	a1,1
    80003df2:	01893503          	ld	a0,24(s2)
    80003df6:	fffff097          	auipc	ra,0xfffff
    80003dfa:	266080e7          	jalr	614(ra) # 8000305c <writei>
    80003dfe:	84aa                	mv	s1,a0
    80003e00:	00a05763          	blez	a0,80003e0e <filewrite+0xc4>
        f->off += r;
    80003e04:	02092783          	lw	a5,32(s2)
    80003e08:	9fa9                	addw	a5,a5,a0
    80003e0a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003e0e:	01893503          	ld	a0,24(s2)
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	f60080e7          	jalr	-160(ra) # 80002d72 <iunlock>
      end_op();
    80003e1a:	00000097          	auipc	ra,0x0
    80003e1e:	8e8080e7          	jalr	-1816(ra) # 80003702 <end_op>

      if(r != n1){
    80003e22:	009c1f63          	bne	s8,s1,80003e40 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003e26:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003e2a:	0149db63          	bge	s3,s4,80003e40 <filewrite+0xf6>
      int n1 = n - i;
    80003e2e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003e32:	84be                	mv	s1,a5
    80003e34:	2781                	sext.w	a5,a5
    80003e36:	f8fb5ce3          	bge	s6,a5,80003dce <filewrite+0x84>
    80003e3a:	84de                	mv	s1,s7
    80003e3c:	bf49                	j	80003dce <filewrite+0x84>
    int i = 0;
    80003e3e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003e40:	013a1f63          	bne	s4,s3,80003e5e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003e44:	8552                	mv	a0,s4
    80003e46:	60a6                	ld	ra,72(sp)
    80003e48:	6406                	ld	s0,64(sp)
    80003e4a:	74e2                	ld	s1,56(sp)
    80003e4c:	7942                	ld	s2,48(sp)
    80003e4e:	79a2                	ld	s3,40(sp)
    80003e50:	7a02                	ld	s4,32(sp)
    80003e52:	6ae2                	ld	s5,24(sp)
    80003e54:	6b42                	ld	s6,16(sp)
    80003e56:	6ba2                	ld	s7,8(sp)
    80003e58:	6c02                	ld	s8,0(sp)
    80003e5a:	6161                	addi	sp,sp,80
    80003e5c:	8082                	ret
    ret = (i == n ? n : -1);
    80003e5e:	5a7d                	li	s4,-1
    80003e60:	b7d5                	j	80003e44 <filewrite+0xfa>
    panic("filewrite");
    80003e62:	00005517          	auipc	a0,0x5
    80003e66:	82650513          	addi	a0,a0,-2010 # 80008688 <syscalls+0x268>
    80003e6a:	00002097          	auipc	ra,0x2
    80003e6e:	efe080e7          	jalr	-258(ra) # 80005d68 <panic>
    return -1;
    80003e72:	5a7d                	li	s4,-1
    80003e74:	bfc1                	j	80003e44 <filewrite+0xfa>
      return -1;
    80003e76:	5a7d                	li	s4,-1
    80003e78:	b7f1                	j	80003e44 <filewrite+0xfa>
    80003e7a:	5a7d                	li	s4,-1
    80003e7c:	b7e1                	j	80003e44 <filewrite+0xfa>

0000000080003e7e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003e7e:	7179                	addi	sp,sp,-48
    80003e80:	f406                	sd	ra,40(sp)
    80003e82:	f022                	sd	s0,32(sp)
    80003e84:	ec26                	sd	s1,24(sp)
    80003e86:	e84a                	sd	s2,16(sp)
    80003e88:	e44e                	sd	s3,8(sp)
    80003e8a:	e052                	sd	s4,0(sp)
    80003e8c:	1800                	addi	s0,sp,48
    80003e8e:	84aa                	mv	s1,a0
    80003e90:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003e92:	0005b023          	sd	zero,0(a1)
    80003e96:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	bf8080e7          	jalr	-1032(ra) # 80003a92 <filealloc>
    80003ea2:	e088                	sd	a0,0(s1)
    80003ea4:	c551                	beqz	a0,80003f30 <pipealloc+0xb2>
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	bec080e7          	jalr	-1044(ra) # 80003a92 <filealloc>
    80003eae:	00aa3023          	sd	a0,0(s4)
    80003eb2:	c92d                	beqz	a0,80003f24 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003eb4:	ffffc097          	auipc	ra,0xffffc
    80003eb8:	36a080e7          	jalr	874(ra) # 8000021e <kalloc>
    80003ebc:	892a                	mv	s2,a0
    80003ebe:	c125                	beqz	a0,80003f1e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003ec0:	4985                	li	s3,1
    80003ec2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003ec6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003eca:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003ece:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003ed2:	00004597          	auipc	a1,0x4
    80003ed6:	7c658593          	addi	a1,a1,1990 # 80008698 <syscalls+0x278>
    80003eda:	00002097          	auipc	ra,0x2
    80003ede:	348080e7          	jalr	840(ra) # 80006222 <initlock>
  (*f0)->type = FD_PIPE;
    80003ee2:	609c                	ld	a5,0(s1)
    80003ee4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003ee8:	609c                	ld	a5,0(s1)
    80003eea:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003eee:	609c                	ld	a5,0(s1)
    80003ef0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003ef4:	609c                	ld	a5,0(s1)
    80003ef6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003efa:	000a3783          	ld	a5,0(s4)
    80003efe:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003f02:	000a3783          	ld	a5,0(s4)
    80003f06:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003f0a:	000a3783          	ld	a5,0(s4)
    80003f0e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003f12:	000a3783          	ld	a5,0(s4)
    80003f16:	0127b823          	sd	s2,16(a5)
  return 0;
    80003f1a:	4501                	li	a0,0
    80003f1c:	a025                	j	80003f44 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003f1e:	6088                	ld	a0,0(s1)
    80003f20:	e501                	bnez	a0,80003f28 <pipealloc+0xaa>
    80003f22:	a039                	j	80003f30 <pipealloc+0xb2>
    80003f24:	6088                	ld	a0,0(s1)
    80003f26:	c51d                	beqz	a0,80003f54 <pipealloc+0xd6>
    fileclose(*f0);
    80003f28:	00000097          	auipc	ra,0x0
    80003f2c:	c26080e7          	jalr	-986(ra) # 80003b4e <fileclose>
  if(*f1)
    80003f30:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003f34:	557d                	li	a0,-1
  if(*f1)
    80003f36:	c799                	beqz	a5,80003f44 <pipealloc+0xc6>
    fileclose(*f1);
    80003f38:	853e                	mv	a0,a5
    80003f3a:	00000097          	auipc	ra,0x0
    80003f3e:	c14080e7          	jalr	-1004(ra) # 80003b4e <fileclose>
  return -1;
    80003f42:	557d                	li	a0,-1
}
    80003f44:	70a2                	ld	ra,40(sp)
    80003f46:	7402                	ld	s0,32(sp)
    80003f48:	64e2                	ld	s1,24(sp)
    80003f4a:	6942                	ld	s2,16(sp)
    80003f4c:	69a2                	ld	s3,8(sp)
    80003f4e:	6a02                	ld	s4,0(sp)
    80003f50:	6145                	addi	sp,sp,48
    80003f52:	8082                	ret
  return -1;
    80003f54:	557d                	li	a0,-1
    80003f56:	b7fd                	j	80003f44 <pipealloc+0xc6>

0000000080003f58 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003f58:	1101                	addi	sp,sp,-32
    80003f5a:	ec06                	sd	ra,24(sp)
    80003f5c:	e822                	sd	s0,16(sp)
    80003f5e:	e426                	sd	s1,8(sp)
    80003f60:	e04a                	sd	s2,0(sp)
    80003f62:	1000                	addi	s0,sp,32
    80003f64:	84aa                	mv	s1,a0
    80003f66:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003f68:	00002097          	auipc	ra,0x2
    80003f6c:	34a080e7          	jalr	842(ra) # 800062b2 <acquire>
  if(writable){
    80003f70:	02090d63          	beqz	s2,80003faa <pipeclose+0x52>
    pi->writeopen = 0;
    80003f74:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003f78:	21848513          	addi	a0,s1,536
    80003f7c:	ffffe097          	auipc	ra,0xffffe
    80003f80:	898080e7          	jalr	-1896(ra) # 80001814 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003f84:	2204b783          	ld	a5,544(s1)
    80003f88:	eb95                	bnez	a5,80003fbc <pipeclose+0x64>
    release(&pi->lock);
    80003f8a:	8526                	mv	a0,s1
    80003f8c:	00002097          	auipc	ra,0x2
    80003f90:	3da080e7          	jalr	986(ra) # 80006366 <release>
    kfree((char*)pi);
    80003f94:	8526                	mv	a0,s1
    80003f96:	ffffc097          	auipc	ra,0xffffc
    80003f9a:	086080e7          	jalr	134(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003f9e:	60e2                	ld	ra,24(sp)
    80003fa0:	6442                	ld	s0,16(sp)
    80003fa2:	64a2                	ld	s1,8(sp)
    80003fa4:	6902                	ld	s2,0(sp)
    80003fa6:	6105                	addi	sp,sp,32
    80003fa8:	8082                	ret
    pi->readopen = 0;
    80003faa:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003fae:	21c48513          	addi	a0,s1,540
    80003fb2:	ffffe097          	auipc	ra,0xffffe
    80003fb6:	862080e7          	jalr	-1950(ra) # 80001814 <wakeup>
    80003fba:	b7e9                	j	80003f84 <pipeclose+0x2c>
    release(&pi->lock);
    80003fbc:	8526                	mv	a0,s1
    80003fbe:	00002097          	auipc	ra,0x2
    80003fc2:	3a8080e7          	jalr	936(ra) # 80006366 <release>
}
    80003fc6:	bfe1                	j	80003f9e <pipeclose+0x46>

0000000080003fc8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003fc8:	7159                	addi	sp,sp,-112
    80003fca:	f486                	sd	ra,104(sp)
    80003fcc:	f0a2                	sd	s0,96(sp)
    80003fce:	eca6                	sd	s1,88(sp)
    80003fd0:	e8ca                	sd	s2,80(sp)
    80003fd2:	e4ce                	sd	s3,72(sp)
    80003fd4:	e0d2                	sd	s4,64(sp)
    80003fd6:	fc56                	sd	s5,56(sp)
    80003fd8:	f85a                	sd	s6,48(sp)
    80003fda:	f45e                	sd	s7,40(sp)
    80003fdc:	f062                	sd	s8,32(sp)
    80003fde:	ec66                	sd	s9,24(sp)
    80003fe0:	1880                	addi	s0,sp,112
    80003fe2:	84aa                	mv	s1,a0
    80003fe4:	8aae                	mv	s5,a1
    80003fe6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	fe4080e7          	jalr	-28(ra) # 80000fcc <myproc>
    80003ff0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	00002097          	auipc	ra,0x2
    80003ff8:	2be080e7          	jalr	702(ra) # 800062b2 <acquire>
  while(i < n){
    80003ffc:	0d405163          	blez	s4,800040be <pipewrite+0xf6>
    80004000:	8ba6                	mv	s7,s1
  int i = 0;
    80004002:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004004:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004006:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000400a:	21c48c13          	addi	s8,s1,540
    8000400e:	a08d                	j	80004070 <pipewrite+0xa8>
      release(&pi->lock);
    80004010:	8526                	mv	a0,s1
    80004012:	00002097          	auipc	ra,0x2
    80004016:	354080e7          	jalr	852(ra) # 80006366 <release>
      return -1;
    8000401a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000401c:	854a                	mv	a0,s2
    8000401e:	70a6                	ld	ra,104(sp)
    80004020:	7406                	ld	s0,96(sp)
    80004022:	64e6                	ld	s1,88(sp)
    80004024:	6946                	ld	s2,80(sp)
    80004026:	69a6                	ld	s3,72(sp)
    80004028:	6a06                	ld	s4,64(sp)
    8000402a:	7ae2                	ld	s5,56(sp)
    8000402c:	7b42                	ld	s6,48(sp)
    8000402e:	7ba2                	ld	s7,40(sp)
    80004030:	7c02                	ld	s8,32(sp)
    80004032:	6ce2                	ld	s9,24(sp)
    80004034:	6165                	addi	sp,sp,112
    80004036:	8082                	ret
      wakeup(&pi->nread);
    80004038:	8566                	mv	a0,s9
    8000403a:	ffffd097          	auipc	ra,0xffffd
    8000403e:	7da080e7          	jalr	2010(ra) # 80001814 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004042:	85de                	mv	a1,s7
    80004044:	8562                	mv	a0,s8
    80004046:	ffffd097          	auipc	ra,0xffffd
    8000404a:	642080e7          	jalr	1602(ra) # 80001688 <sleep>
    8000404e:	a839                	j	8000406c <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004050:	21c4a783          	lw	a5,540(s1)
    80004054:	0017871b          	addiw	a4,a5,1
    80004058:	20e4ae23          	sw	a4,540(s1)
    8000405c:	1ff7f793          	andi	a5,a5,511
    80004060:	97a6                	add	a5,a5,s1
    80004062:	f9f44703          	lbu	a4,-97(s0)
    80004066:	00e78c23          	sb	a4,24(a5)
      i++;
    8000406a:	2905                	addiw	s2,s2,1
  while(i < n){
    8000406c:	03495d63          	bge	s2,s4,800040a6 <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004070:	2204a783          	lw	a5,544(s1)
    80004074:	dfd1                	beqz	a5,80004010 <pipewrite+0x48>
    80004076:	0289a783          	lw	a5,40(s3)
    8000407a:	fbd9                	bnez	a5,80004010 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000407c:	2184a783          	lw	a5,536(s1)
    80004080:	21c4a703          	lw	a4,540(s1)
    80004084:	2007879b          	addiw	a5,a5,512
    80004088:	faf708e3          	beq	a4,a5,80004038 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000408c:	4685                	li	a3,1
    8000408e:	01590633          	add	a2,s2,s5
    80004092:	f9f40593          	addi	a1,s0,-97
    80004096:	0509b503          	ld	a0,80(s3)
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	c80080e7          	jalr	-896(ra) # 80000d1a <copyin>
    800040a2:	fb6517e3          	bne	a0,s6,80004050 <pipewrite+0x88>
  wakeup(&pi->nread);
    800040a6:	21848513          	addi	a0,s1,536
    800040aa:	ffffd097          	auipc	ra,0xffffd
    800040ae:	76a080e7          	jalr	1898(ra) # 80001814 <wakeup>
  release(&pi->lock);
    800040b2:	8526                	mv	a0,s1
    800040b4:	00002097          	auipc	ra,0x2
    800040b8:	2b2080e7          	jalr	690(ra) # 80006366 <release>
  return i;
    800040bc:	b785                	j	8000401c <pipewrite+0x54>
  int i = 0;
    800040be:	4901                	li	s2,0
    800040c0:	b7dd                	j	800040a6 <pipewrite+0xde>

00000000800040c2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800040c2:	715d                	addi	sp,sp,-80
    800040c4:	e486                	sd	ra,72(sp)
    800040c6:	e0a2                	sd	s0,64(sp)
    800040c8:	fc26                	sd	s1,56(sp)
    800040ca:	f84a                	sd	s2,48(sp)
    800040cc:	f44e                	sd	s3,40(sp)
    800040ce:	f052                	sd	s4,32(sp)
    800040d0:	ec56                	sd	s5,24(sp)
    800040d2:	e85a                	sd	s6,16(sp)
    800040d4:	0880                	addi	s0,sp,80
    800040d6:	84aa                	mv	s1,a0
    800040d8:	892e                	mv	s2,a1
    800040da:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800040dc:	ffffd097          	auipc	ra,0xffffd
    800040e0:	ef0080e7          	jalr	-272(ra) # 80000fcc <myproc>
    800040e4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800040e6:	8b26                	mv	s6,s1
    800040e8:	8526                	mv	a0,s1
    800040ea:	00002097          	auipc	ra,0x2
    800040ee:	1c8080e7          	jalr	456(ra) # 800062b2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800040f2:	2184a703          	lw	a4,536(s1)
    800040f6:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800040fa:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800040fe:	02f71463          	bne	a4,a5,80004126 <piperead+0x64>
    80004102:	2244a783          	lw	a5,548(s1)
    80004106:	c385                	beqz	a5,80004126 <piperead+0x64>
    if(pr->killed){
    80004108:	028a2783          	lw	a5,40(s4)
    8000410c:	ebc1                	bnez	a5,8000419c <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000410e:	85da                	mv	a1,s6
    80004110:	854e                	mv	a0,s3
    80004112:	ffffd097          	auipc	ra,0xffffd
    80004116:	576080e7          	jalr	1398(ra) # 80001688 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000411a:	2184a703          	lw	a4,536(s1)
    8000411e:	21c4a783          	lw	a5,540(s1)
    80004122:	fef700e3          	beq	a4,a5,80004102 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004126:	09505263          	blez	s5,800041aa <piperead+0xe8>
    8000412a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000412c:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000412e:	2184a783          	lw	a5,536(s1)
    80004132:	21c4a703          	lw	a4,540(s1)
    80004136:	02f70d63          	beq	a4,a5,80004170 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000413a:	0017871b          	addiw	a4,a5,1
    8000413e:	20e4ac23          	sw	a4,536(s1)
    80004142:	1ff7f793          	andi	a5,a5,511
    80004146:	97a6                	add	a5,a5,s1
    80004148:	0187c783          	lbu	a5,24(a5)
    8000414c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004150:	4685                	li	a3,1
    80004152:	fbf40613          	addi	a2,s0,-65
    80004156:	85ca                	mv	a1,s2
    80004158:	050a3503          	ld	a0,80(s4)
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	ae6080e7          	jalr	-1306(ra) # 80000c42 <copyout>
    80004164:	01650663          	beq	a0,s6,80004170 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004168:	2985                	addiw	s3,s3,1
    8000416a:	0905                	addi	s2,s2,1
    8000416c:	fd3a91e3          	bne	s5,s3,8000412e <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004170:	21c48513          	addi	a0,s1,540
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	6a0080e7          	jalr	1696(ra) # 80001814 <wakeup>
  release(&pi->lock);
    8000417c:	8526                	mv	a0,s1
    8000417e:	00002097          	auipc	ra,0x2
    80004182:	1e8080e7          	jalr	488(ra) # 80006366 <release>
  return i;
}
    80004186:	854e                	mv	a0,s3
    80004188:	60a6                	ld	ra,72(sp)
    8000418a:	6406                	ld	s0,64(sp)
    8000418c:	74e2                	ld	s1,56(sp)
    8000418e:	7942                	ld	s2,48(sp)
    80004190:	79a2                	ld	s3,40(sp)
    80004192:	7a02                	ld	s4,32(sp)
    80004194:	6ae2                	ld	s5,24(sp)
    80004196:	6b42                	ld	s6,16(sp)
    80004198:	6161                	addi	sp,sp,80
    8000419a:	8082                	ret
      release(&pi->lock);
    8000419c:	8526                	mv	a0,s1
    8000419e:	00002097          	auipc	ra,0x2
    800041a2:	1c8080e7          	jalr	456(ra) # 80006366 <release>
      return -1;
    800041a6:	59fd                	li	s3,-1
    800041a8:	bff9                	j	80004186 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800041aa:	4981                	li	s3,0
    800041ac:	b7d1                	j	80004170 <piperead+0xae>

00000000800041ae <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    800041ae:	df010113          	addi	sp,sp,-528
    800041b2:	20113423          	sd	ra,520(sp)
    800041b6:	20813023          	sd	s0,512(sp)
    800041ba:	ffa6                	sd	s1,504(sp)
    800041bc:	fbca                	sd	s2,496(sp)
    800041be:	f7ce                	sd	s3,488(sp)
    800041c0:	f3d2                	sd	s4,480(sp)
    800041c2:	efd6                	sd	s5,472(sp)
    800041c4:	ebda                	sd	s6,464(sp)
    800041c6:	e7de                	sd	s7,456(sp)
    800041c8:	e3e2                	sd	s8,448(sp)
    800041ca:	ff66                	sd	s9,440(sp)
    800041cc:	fb6a                	sd	s10,432(sp)
    800041ce:	f76e                	sd	s11,424(sp)
    800041d0:	0c00                	addi	s0,sp,528
    800041d2:	84aa                	mv	s1,a0
    800041d4:	dea43c23          	sd	a0,-520(s0)
    800041d8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800041dc:	ffffd097          	auipc	ra,0xffffd
    800041e0:	df0080e7          	jalr	-528(ra) # 80000fcc <myproc>
    800041e4:	892a                	mv	s2,a0

  begin_op();
    800041e6:	fffff097          	auipc	ra,0xfffff
    800041ea:	49c080e7          	jalr	1180(ra) # 80003682 <begin_op>

  if((ip = namei(path)) == 0){
    800041ee:	8526                	mv	a0,s1
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	276080e7          	jalr	630(ra) # 80003466 <namei>
    800041f8:	c92d                	beqz	a0,8000426a <exec+0xbc>
    800041fa:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800041fc:	fffff097          	auipc	ra,0xfffff
    80004200:	ab4080e7          	jalr	-1356(ra) # 80002cb0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004204:	04000713          	li	a4,64
    80004208:	4681                	li	a3,0
    8000420a:	e5040613          	addi	a2,s0,-432
    8000420e:	4581                	li	a1,0
    80004210:	8526                	mv	a0,s1
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	d52080e7          	jalr	-686(ra) # 80002f64 <readi>
    8000421a:	04000793          	li	a5,64
    8000421e:	00f51a63          	bne	a0,a5,80004232 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004222:	e5042703          	lw	a4,-432(s0)
    80004226:	464c47b7          	lui	a5,0x464c4
    8000422a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000422e:	04f70463          	beq	a4,a5,80004276 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004232:	8526                	mv	a0,s1
    80004234:	fffff097          	auipc	ra,0xfffff
    80004238:	cde080e7          	jalr	-802(ra) # 80002f12 <iunlockput>
    end_op();
    8000423c:	fffff097          	auipc	ra,0xfffff
    80004240:	4c6080e7          	jalr	1222(ra) # 80003702 <end_op>
  }
  return -1;
    80004244:	557d                	li	a0,-1
}
    80004246:	20813083          	ld	ra,520(sp)
    8000424a:	20013403          	ld	s0,512(sp)
    8000424e:	74fe                	ld	s1,504(sp)
    80004250:	795e                	ld	s2,496(sp)
    80004252:	79be                	ld	s3,488(sp)
    80004254:	7a1e                	ld	s4,480(sp)
    80004256:	6afe                	ld	s5,472(sp)
    80004258:	6b5e                	ld	s6,464(sp)
    8000425a:	6bbe                	ld	s7,456(sp)
    8000425c:	6c1e                	ld	s8,448(sp)
    8000425e:	7cfa                	ld	s9,440(sp)
    80004260:	7d5a                	ld	s10,432(sp)
    80004262:	7dba                	ld	s11,424(sp)
    80004264:	21010113          	addi	sp,sp,528
    80004268:	8082                	ret
    end_op();
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	498080e7          	jalr	1176(ra) # 80003702 <end_op>
    return -1;
    80004272:	557d                	li	a0,-1
    80004274:	bfc9                	j	80004246 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004276:	854a                	mv	a0,s2
    80004278:	ffffd097          	auipc	ra,0xffffd
    8000427c:	e18080e7          	jalr	-488(ra) # 80001090 <proc_pagetable>
    80004280:	8baa                	mv	s7,a0
    80004282:	d945                	beqz	a0,80004232 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004284:	e7042983          	lw	s3,-400(s0)
    80004288:	e8845783          	lhu	a5,-376(s0)
    8000428c:	c7ad                	beqz	a5,800042f6 <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000428e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004290:	4b01                	li	s6,0
    if((ph.vaddr % PGSIZE) != 0)
    80004292:	6c85                	lui	s9,0x1
    80004294:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004298:	def43823          	sd	a5,-528(s0)
    8000429c:	a42d                	j	800044c6 <exec+0x318>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000429e:	00004517          	auipc	a0,0x4
    800042a2:	40250513          	addi	a0,a0,1026 # 800086a0 <syscalls+0x280>
    800042a6:	00002097          	auipc	ra,0x2
    800042aa:	ac2080e7          	jalr	-1342(ra) # 80005d68 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800042ae:	8756                	mv	a4,s5
    800042b0:	012d86bb          	addw	a3,s11,s2
    800042b4:	4581                	li	a1,0
    800042b6:	8526                	mv	a0,s1
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	cac080e7          	jalr	-852(ra) # 80002f64 <readi>
    800042c0:	2501                	sext.w	a0,a0
    800042c2:	1aaa9963          	bne	s5,a0,80004474 <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800042c6:	6785                	lui	a5,0x1
    800042c8:	0127893b          	addw	s2,a5,s2
    800042cc:	77fd                	lui	a5,0xfffff
    800042ce:	01478a3b          	addw	s4,a5,s4
    800042d2:	1f897163          	bgeu	s2,s8,800044b4 <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800042d6:	02091593          	slli	a1,s2,0x20
    800042da:	9181                	srli	a1,a1,0x20
    800042dc:	95ea                	add	a1,a1,s10
    800042de:	855e                	mv	a0,s7
    800042e0:	ffffc097          	auipc	ra,0xffffc
    800042e4:	362080e7          	jalr	866(ra) # 80000642 <walkaddr>
    800042e8:	862a                	mv	a2,a0
    if(pa == 0)
    800042ea:	d955                	beqz	a0,8000429e <exec+0xf0>
      n = PGSIZE;
    800042ec:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800042ee:	fd9a70e3          	bgeu	s4,s9,800042ae <exec+0x100>
      n = sz - i;
    800042f2:	8ad2                	mv	s5,s4
    800042f4:	bf6d                	j	800042ae <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800042f6:	4901                	li	s2,0
  iunlockput(ip);
    800042f8:	8526                	mv	a0,s1
    800042fa:	fffff097          	auipc	ra,0xfffff
    800042fe:	c18080e7          	jalr	-1000(ra) # 80002f12 <iunlockput>
  end_op();
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	400080e7          	jalr	1024(ra) # 80003702 <end_op>
  p = myproc();
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	cc2080e7          	jalr	-830(ra) # 80000fcc <myproc>
    80004312:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004314:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004318:	6785                	lui	a5,0x1
    8000431a:	17fd                	addi	a5,a5,-1
    8000431c:	993e                	add	s2,s2,a5
    8000431e:	757d                	lui	a0,0xfffff
    80004320:	00a977b3          	and	a5,s2,a0
    80004324:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004328:	6609                	lui	a2,0x2
    8000432a:	963e                	add	a2,a2,a5
    8000432c:	85be                	mv	a1,a5
    8000432e:	855e                	mv	a0,s7
    80004330:	ffffc097          	auipc	ra,0xffffc
    80004334:	6cc080e7          	jalr	1740(ra) # 800009fc <uvmalloc>
    80004338:	8b2a                	mv	s6,a0
  ip = 0;
    8000433a:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000433c:	12050c63          	beqz	a0,80004474 <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004340:	75f9                	lui	a1,0xffffe
    80004342:	95aa                	add	a1,a1,a0
    80004344:	855e                	mv	a0,s7
    80004346:	ffffd097          	auipc	ra,0xffffd
    8000434a:	8ca080e7          	jalr	-1846(ra) # 80000c10 <uvmclear>
  stackbase = sp - PGSIZE;
    8000434e:	7c7d                	lui	s8,0xfffff
    80004350:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004352:	e0043783          	ld	a5,-512(s0)
    80004356:	6388                	ld	a0,0(a5)
    80004358:	c535                	beqz	a0,800043c4 <exec+0x216>
    8000435a:	e9040993          	addi	s3,s0,-368
    8000435e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004362:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004364:	ffffc097          	auipc	ra,0xffffc
    80004368:	0d4080e7          	jalr	212(ra) # 80000438 <strlen>
    8000436c:	2505                	addiw	a0,a0,1
    8000436e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004372:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004376:	13896363          	bltu	s2,s8,8000449c <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000437a:	e0043d83          	ld	s11,-512(s0)
    8000437e:	000dba03          	ld	s4,0(s11)
    80004382:	8552                	mv	a0,s4
    80004384:	ffffc097          	auipc	ra,0xffffc
    80004388:	0b4080e7          	jalr	180(ra) # 80000438 <strlen>
    8000438c:	0015069b          	addiw	a3,a0,1
    80004390:	8652                	mv	a2,s4
    80004392:	85ca                	mv	a1,s2
    80004394:	855e                	mv	a0,s7
    80004396:	ffffd097          	auipc	ra,0xffffd
    8000439a:	8ac080e7          	jalr	-1876(ra) # 80000c42 <copyout>
    8000439e:	10054363          	bltz	a0,800044a4 <exec+0x2f6>
    ustack[argc] = sp;
    800043a2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800043a6:	0485                	addi	s1,s1,1
    800043a8:	008d8793          	addi	a5,s11,8
    800043ac:	e0f43023          	sd	a5,-512(s0)
    800043b0:	008db503          	ld	a0,8(s11)
    800043b4:	c911                	beqz	a0,800043c8 <exec+0x21a>
    if(argc >= MAXARG)
    800043b6:	09a1                	addi	s3,s3,8
    800043b8:	fb3c96e3          	bne	s9,s3,80004364 <exec+0x1b6>
  sz = sz1;
    800043bc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043c0:	4481                	li	s1,0
    800043c2:	a84d                	j	80004474 <exec+0x2c6>
  sp = sz;
    800043c4:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800043c6:	4481                	li	s1,0
  ustack[argc] = 0;
    800043c8:	00349793          	slli	a5,s1,0x3
    800043cc:	f9040713          	addi	a4,s0,-112
    800043d0:	97ba                	add	a5,a5,a4
    800043d2:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800043d6:	00148693          	addi	a3,s1,1
    800043da:	068e                	slli	a3,a3,0x3
    800043dc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800043e0:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800043e4:	01897663          	bgeu	s2,s8,800043f0 <exec+0x242>
  sz = sz1;
    800043e8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800043ec:	4481                	li	s1,0
    800043ee:	a059                	j	80004474 <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800043f0:	e9040613          	addi	a2,s0,-368
    800043f4:	85ca                	mv	a1,s2
    800043f6:	855e                	mv	a0,s7
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	84a080e7          	jalr	-1974(ra) # 80000c42 <copyout>
    80004400:	0a054663          	bltz	a0,800044ac <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004404:	058ab783          	ld	a5,88(s5)
    80004408:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000440c:	df843783          	ld	a5,-520(s0)
    80004410:	0007c703          	lbu	a4,0(a5)
    80004414:	cf11                	beqz	a4,80004430 <exec+0x282>
    80004416:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004418:	02f00693          	li	a3,47
    8000441c:	a039                	j	8000442a <exec+0x27c>
      last = s+1;
    8000441e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004422:	0785                	addi	a5,a5,1
    80004424:	fff7c703          	lbu	a4,-1(a5)
    80004428:	c701                	beqz	a4,80004430 <exec+0x282>
    if(*s == '/')
    8000442a:	fed71ce3          	bne	a4,a3,80004422 <exec+0x274>
    8000442e:	bfc5                	j	8000441e <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004430:	4641                	li	a2,16
    80004432:	df843583          	ld	a1,-520(s0)
    80004436:	158a8513          	addi	a0,s5,344
    8000443a:	ffffc097          	auipc	ra,0xffffc
    8000443e:	fcc080e7          	jalr	-52(ra) # 80000406 <safestrcpy>
  oldpagetable = p->pagetable;
    80004442:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004446:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    8000444a:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000444e:	058ab783          	ld	a5,88(s5)
    80004452:	e6843703          	ld	a4,-408(s0)
    80004456:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004458:	058ab783          	ld	a5,88(s5)
    8000445c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004460:	85ea                	mv	a1,s10
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	cca080e7          	jalr	-822(ra) # 8000112c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000446a:	0004851b          	sext.w	a0,s1
    8000446e:	bbe1                	j	80004246 <exec+0x98>
    80004470:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004474:	e0843583          	ld	a1,-504(s0)
    80004478:	855e                	mv	a0,s7
    8000447a:	ffffd097          	auipc	ra,0xffffd
    8000447e:	cb2080e7          	jalr	-846(ra) # 8000112c <proc_freepagetable>
  if(ip){
    80004482:	da0498e3          	bnez	s1,80004232 <exec+0x84>
  return -1;
    80004486:	557d                	li	a0,-1
    80004488:	bb7d                	j	80004246 <exec+0x98>
    8000448a:	e1243423          	sd	s2,-504(s0)
    8000448e:	b7dd                	j	80004474 <exec+0x2c6>
    80004490:	e1243423          	sd	s2,-504(s0)
    80004494:	b7c5                	j	80004474 <exec+0x2c6>
    80004496:	e1243423          	sd	s2,-504(s0)
    8000449a:	bfe9                	j	80004474 <exec+0x2c6>
  sz = sz1;
    8000449c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800044a0:	4481                	li	s1,0
    800044a2:	bfc9                	j	80004474 <exec+0x2c6>
  sz = sz1;
    800044a4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800044a8:	4481                	li	s1,0
    800044aa:	b7e9                	j	80004474 <exec+0x2c6>
  sz = sz1;
    800044ac:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800044b0:	4481                	li	s1,0
    800044b2:	b7c9                	j	80004474 <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800044b4:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800044b8:	2b05                	addiw	s6,s6,1
    800044ba:	0389899b          	addiw	s3,s3,56
    800044be:	e8845783          	lhu	a5,-376(s0)
    800044c2:	e2fb5be3          	bge	s6,a5,800042f8 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800044c6:	2981                	sext.w	s3,s3
    800044c8:	03800713          	li	a4,56
    800044cc:	86ce                	mv	a3,s3
    800044ce:	e1840613          	addi	a2,s0,-488
    800044d2:	4581                	li	a1,0
    800044d4:	8526                	mv	a0,s1
    800044d6:	fffff097          	auipc	ra,0xfffff
    800044da:	a8e080e7          	jalr	-1394(ra) # 80002f64 <readi>
    800044de:	03800793          	li	a5,56
    800044e2:	f8f517e3          	bne	a0,a5,80004470 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800044e6:	e1842783          	lw	a5,-488(s0)
    800044ea:	4705                	li	a4,1
    800044ec:	fce796e3          	bne	a5,a4,800044b8 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    800044f0:	e4043603          	ld	a2,-448(s0)
    800044f4:	e3843783          	ld	a5,-456(s0)
    800044f8:	f8f669e3          	bltu	a2,a5,8000448a <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800044fc:	e2843783          	ld	a5,-472(s0)
    80004500:	963e                	add	a2,a2,a5
    80004502:	f8f667e3          	bltu	a2,a5,80004490 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004506:	85ca                	mv	a1,s2
    80004508:	855e                	mv	a0,s7
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	4f2080e7          	jalr	1266(ra) # 800009fc <uvmalloc>
    80004512:	e0a43423          	sd	a0,-504(s0)
    80004516:	d141                	beqz	a0,80004496 <exec+0x2e8>
    if((ph.vaddr % PGSIZE) != 0)
    80004518:	e2843d03          	ld	s10,-472(s0)
    8000451c:	df043783          	ld	a5,-528(s0)
    80004520:	00fd77b3          	and	a5,s10,a5
    80004524:	fba1                	bnez	a5,80004474 <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004526:	e2042d83          	lw	s11,-480(s0)
    8000452a:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000452e:	f80c03e3          	beqz	s8,800044b4 <exec+0x306>
    80004532:	8a62                	mv	s4,s8
    80004534:	4901                	li	s2,0
    80004536:	b345                	j	800042d6 <exec+0x128>

0000000080004538 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004538:	7179                	addi	sp,sp,-48
    8000453a:	f406                	sd	ra,40(sp)
    8000453c:	f022                	sd	s0,32(sp)
    8000453e:	ec26                	sd	s1,24(sp)
    80004540:	e84a                	sd	s2,16(sp)
    80004542:	1800                	addi	s0,sp,48
    80004544:	892e                	mv	s2,a1
    80004546:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004548:	fdc40593          	addi	a1,s0,-36
    8000454c:	ffffe097          	auipc	ra,0xffffe
    80004550:	bf2080e7          	jalr	-1038(ra) # 8000213e <argint>
    80004554:	04054063          	bltz	a0,80004594 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004558:	fdc42703          	lw	a4,-36(s0)
    8000455c:	47bd                	li	a5,15
    8000455e:	02e7ed63          	bltu	a5,a4,80004598 <argfd+0x60>
    80004562:	ffffd097          	auipc	ra,0xffffd
    80004566:	a6a080e7          	jalr	-1430(ra) # 80000fcc <myproc>
    8000456a:	fdc42703          	lw	a4,-36(s0)
    8000456e:	01a70793          	addi	a5,a4,26
    80004572:	078e                	slli	a5,a5,0x3
    80004574:	953e                	add	a0,a0,a5
    80004576:	611c                	ld	a5,0(a0)
    80004578:	c395                	beqz	a5,8000459c <argfd+0x64>
    return -1;
  if(pfd)
    8000457a:	00090463          	beqz	s2,80004582 <argfd+0x4a>
    *pfd = fd;
    8000457e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004582:	4501                	li	a0,0
  if(pf)
    80004584:	c091                	beqz	s1,80004588 <argfd+0x50>
    *pf = f;
    80004586:	e09c                	sd	a5,0(s1)
}
    80004588:	70a2                	ld	ra,40(sp)
    8000458a:	7402                	ld	s0,32(sp)
    8000458c:	64e2                	ld	s1,24(sp)
    8000458e:	6942                	ld	s2,16(sp)
    80004590:	6145                	addi	sp,sp,48
    80004592:	8082                	ret
    return -1;
    80004594:	557d                	li	a0,-1
    80004596:	bfcd                	j	80004588 <argfd+0x50>
    return -1;
    80004598:	557d                	li	a0,-1
    8000459a:	b7fd                	j	80004588 <argfd+0x50>
    8000459c:	557d                	li	a0,-1
    8000459e:	b7ed                	j	80004588 <argfd+0x50>

00000000800045a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800045a0:	1101                	addi	sp,sp,-32
    800045a2:	ec06                	sd	ra,24(sp)
    800045a4:	e822                	sd	s0,16(sp)
    800045a6:	e426                	sd	s1,8(sp)
    800045a8:	1000                	addi	s0,sp,32
    800045aa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800045ac:	ffffd097          	auipc	ra,0xffffd
    800045b0:	a20080e7          	jalr	-1504(ra) # 80000fcc <myproc>
    800045b4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800045b6:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7fdb8e90>
    800045ba:	4501                	li	a0,0
    800045bc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800045be:	6398                	ld	a4,0(a5)
    800045c0:	cb19                	beqz	a4,800045d6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800045c2:	2505                	addiw	a0,a0,1
    800045c4:	07a1                	addi	a5,a5,8
    800045c6:	fed51ce3          	bne	a0,a3,800045be <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800045ca:	557d                	li	a0,-1
}
    800045cc:	60e2                	ld	ra,24(sp)
    800045ce:	6442                	ld	s0,16(sp)
    800045d0:	64a2                	ld	s1,8(sp)
    800045d2:	6105                	addi	sp,sp,32
    800045d4:	8082                	ret
      p->ofile[fd] = f;
    800045d6:	01a50793          	addi	a5,a0,26
    800045da:	078e                	slli	a5,a5,0x3
    800045dc:	963e                	add	a2,a2,a5
    800045de:	e204                	sd	s1,0(a2)
      return fd;
    800045e0:	b7f5                	j	800045cc <fdalloc+0x2c>

00000000800045e2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800045e2:	715d                	addi	sp,sp,-80
    800045e4:	e486                	sd	ra,72(sp)
    800045e6:	e0a2                	sd	s0,64(sp)
    800045e8:	fc26                	sd	s1,56(sp)
    800045ea:	f84a                	sd	s2,48(sp)
    800045ec:	f44e                	sd	s3,40(sp)
    800045ee:	f052                	sd	s4,32(sp)
    800045f0:	ec56                	sd	s5,24(sp)
    800045f2:	0880                	addi	s0,sp,80
    800045f4:	89ae                	mv	s3,a1
    800045f6:	8ab2                	mv	s5,a2
    800045f8:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800045fa:	fb040593          	addi	a1,s0,-80
    800045fe:	fffff097          	auipc	ra,0xfffff
    80004602:	e86080e7          	jalr	-378(ra) # 80003484 <nameiparent>
    80004606:	892a                	mv	s2,a0
    80004608:	12050f63          	beqz	a0,80004746 <create+0x164>
    return 0;

  ilock(dp);
    8000460c:	ffffe097          	auipc	ra,0xffffe
    80004610:	6a4080e7          	jalr	1700(ra) # 80002cb0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004614:	4601                	li	a2,0
    80004616:	fb040593          	addi	a1,s0,-80
    8000461a:	854a                	mv	a0,s2
    8000461c:	fffff097          	auipc	ra,0xfffff
    80004620:	b78080e7          	jalr	-1160(ra) # 80003194 <dirlookup>
    80004624:	84aa                	mv	s1,a0
    80004626:	c921                	beqz	a0,80004676 <create+0x94>
    iunlockput(dp);
    80004628:	854a                	mv	a0,s2
    8000462a:	fffff097          	auipc	ra,0xfffff
    8000462e:	8e8080e7          	jalr	-1816(ra) # 80002f12 <iunlockput>
    ilock(ip);
    80004632:	8526                	mv	a0,s1
    80004634:	ffffe097          	auipc	ra,0xffffe
    80004638:	67c080e7          	jalr	1660(ra) # 80002cb0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000463c:	2981                	sext.w	s3,s3
    8000463e:	4789                	li	a5,2
    80004640:	02f99463          	bne	s3,a5,80004668 <create+0x86>
    80004644:	0444d783          	lhu	a5,68(s1)
    80004648:	37f9                	addiw	a5,a5,-2
    8000464a:	17c2                	slli	a5,a5,0x30
    8000464c:	93c1                	srli	a5,a5,0x30
    8000464e:	4705                	li	a4,1
    80004650:	00f76c63          	bltu	a4,a5,80004668 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004654:	8526                	mv	a0,s1
    80004656:	60a6                	ld	ra,72(sp)
    80004658:	6406                	ld	s0,64(sp)
    8000465a:	74e2                	ld	s1,56(sp)
    8000465c:	7942                	ld	s2,48(sp)
    8000465e:	79a2                	ld	s3,40(sp)
    80004660:	7a02                	ld	s4,32(sp)
    80004662:	6ae2                	ld	s5,24(sp)
    80004664:	6161                	addi	sp,sp,80
    80004666:	8082                	ret
    iunlockput(ip);
    80004668:	8526                	mv	a0,s1
    8000466a:	fffff097          	auipc	ra,0xfffff
    8000466e:	8a8080e7          	jalr	-1880(ra) # 80002f12 <iunlockput>
    return 0;
    80004672:	4481                	li	s1,0
    80004674:	b7c5                	j	80004654 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004676:	85ce                	mv	a1,s3
    80004678:	00092503          	lw	a0,0(s2)
    8000467c:	ffffe097          	auipc	ra,0xffffe
    80004680:	49c080e7          	jalr	1180(ra) # 80002b18 <ialloc>
    80004684:	84aa                	mv	s1,a0
    80004686:	c529                	beqz	a0,800046d0 <create+0xee>
  ilock(ip);
    80004688:	ffffe097          	auipc	ra,0xffffe
    8000468c:	628080e7          	jalr	1576(ra) # 80002cb0 <ilock>
  ip->major = major;
    80004690:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004694:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004698:	4785                	li	a5,1
    8000469a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000469e:	8526                	mv	a0,s1
    800046a0:	ffffe097          	auipc	ra,0xffffe
    800046a4:	546080e7          	jalr	1350(ra) # 80002be6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800046a8:	2981                	sext.w	s3,s3
    800046aa:	4785                	li	a5,1
    800046ac:	02f98a63          	beq	s3,a5,800046e0 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800046b0:	40d0                	lw	a2,4(s1)
    800046b2:	fb040593          	addi	a1,s0,-80
    800046b6:	854a                	mv	a0,s2
    800046b8:	fffff097          	auipc	ra,0xfffff
    800046bc:	cec080e7          	jalr	-788(ra) # 800033a4 <dirlink>
    800046c0:	06054b63          	bltz	a0,80004736 <create+0x154>
  iunlockput(dp);
    800046c4:	854a                	mv	a0,s2
    800046c6:	fffff097          	auipc	ra,0xfffff
    800046ca:	84c080e7          	jalr	-1972(ra) # 80002f12 <iunlockput>
  return ip;
    800046ce:	b759                	j	80004654 <create+0x72>
    panic("create: ialloc");
    800046d0:	00004517          	auipc	a0,0x4
    800046d4:	ff050513          	addi	a0,a0,-16 # 800086c0 <syscalls+0x2a0>
    800046d8:	00001097          	auipc	ra,0x1
    800046dc:	690080e7          	jalr	1680(ra) # 80005d68 <panic>
    dp->nlink++;  // for ".."
    800046e0:	04a95783          	lhu	a5,74(s2)
    800046e4:	2785                	addiw	a5,a5,1
    800046e6:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800046ea:	854a                	mv	a0,s2
    800046ec:	ffffe097          	auipc	ra,0xffffe
    800046f0:	4fa080e7          	jalr	1274(ra) # 80002be6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800046f4:	40d0                	lw	a2,4(s1)
    800046f6:	00004597          	auipc	a1,0x4
    800046fa:	fda58593          	addi	a1,a1,-38 # 800086d0 <syscalls+0x2b0>
    800046fe:	8526                	mv	a0,s1
    80004700:	fffff097          	auipc	ra,0xfffff
    80004704:	ca4080e7          	jalr	-860(ra) # 800033a4 <dirlink>
    80004708:	00054f63          	bltz	a0,80004726 <create+0x144>
    8000470c:	00492603          	lw	a2,4(s2)
    80004710:	00004597          	auipc	a1,0x4
    80004714:	fc858593          	addi	a1,a1,-56 # 800086d8 <syscalls+0x2b8>
    80004718:	8526                	mv	a0,s1
    8000471a:	fffff097          	auipc	ra,0xfffff
    8000471e:	c8a080e7          	jalr	-886(ra) # 800033a4 <dirlink>
    80004722:	f80557e3          	bgez	a0,800046b0 <create+0xce>
      panic("create dots");
    80004726:	00004517          	auipc	a0,0x4
    8000472a:	fba50513          	addi	a0,a0,-70 # 800086e0 <syscalls+0x2c0>
    8000472e:	00001097          	auipc	ra,0x1
    80004732:	63a080e7          	jalr	1594(ra) # 80005d68 <panic>
    panic("create: dirlink");
    80004736:	00004517          	auipc	a0,0x4
    8000473a:	fba50513          	addi	a0,a0,-70 # 800086f0 <syscalls+0x2d0>
    8000473e:	00001097          	auipc	ra,0x1
    80004742:	62a080e7          	jalr	1578(ra) # 80005d68 <panic>
    return 0;
    80004746:	84aa                	mv	s1,a0
    80004748:	b731                	j	80004654 <create+0x72>

000000008000474a <sys_dup>:
{
    8000474a:	7179                	addi	sp,sp,-48
    8000474c:	f406                	sd	ra,40(sp)
    8000474e:	f022                	sd	s0,32(sp)
    80004750:	ec26                	sd	s1,24(sp)
    80004752:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004754:	fd840613          	addi	a2,s0,-40
    80004758:	4581                	li	a1,0
    8000475a:	4501                	li	a0,0
    8000475c:	00000097          	auipc	ra,0x0
    80004760:	ddc080e7          	jalr	-548(ra) # 80004538 <argfd>
    return -1;
    80004764:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004766:	02054363          	bltz	a0,8000478c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000476a:	fd843503          	ld	a0,-40(s0)
    8000476e:	00000097          	auipc	ra,0x0
    80004772:	e32080e7          	jalr	-462(ra) # 800045a0 <fdalloc>
    80004776:	84aa                	mv	s1,a0
    return -1;
    80004778:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000477a:	00054963          	bltz	a0,8000478c <sys_dup+0x42>
  filedup(f);
    8000477e:	fd843503          	ld	a0,-40(s0)
    80004782:	fffff097          	auipc	ra,0xfffff
    80004786:	37a080e7          	jalr	890(ra) # 80003afc <filedup>
  return fd;
    8000478a:	87a6                	mv	a5,s1
}
    8000478c:	853e                	mv	a0,a5
    8000478e:	70a2                	ld	ra,40(sp)
    80004790:	7402                	ld	s0,32(sp)
    80004792:	64e2                	ld	s1,24(sp)
    80004794:	6145                	addi	sp,sp,48
    80004796:	8082                	ret

0000000080004798 <sys_read>:
{
    80004798:	7179                	addi	sp,sp,-48
    8000479a:	f406                	sd	ra,40(sp)
    8000479c:	f022                	sd	s0,32(sp)
    8000479e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047a0:	fe840613          	addi	a2,s0,-24
    800047a4:	4581                	li	a1,0
    800047a6:	4501                	li	a0,0
    800047a8:	00000097          	auipc	ra,0x0
    800047ac:	d90080e7          	jalr	-624(ra) # 80004538 <argfd>
    return -1;
    800047b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047b2:	04054163          	bltz	a0,800047f4 <sys_read+0x5c>
    800047b6:	fe440593          	addi	a1,s0,-28
    800047ba:	4509                	li	a0,2
    800047bc:	ffffe097          	auipc	ra,0xffffe
    800047c0:	982080e7          	jalr	-1662(ra) # 8000213e <argint>
    return -1;
    800047c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047c6:	02054763          	bltz	a0,800047f4 <sys_read+0x5c>
    800047ca:	fd840593          	addi	a1,s0,-40
    800047ce:	4505                	li	a0,1
    800047d0:	ffffe097          	auipc	ra,0xffffe
    800047d4:	990080e7          	jalr	-1648(ra) # 80002160 <argaddr>
    return -1;
    800047d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047da:	00054d63          	bltz	a0,800047f4 <sys_read+0x5c>
  return fileread(f, p, n);
    800047de:	fe442603          	lw	a2,-28(s0)
    800047e2:	fd843583          	ld	a1,-40(s0)
    800047e6:	fe843503          	ld	a0,-24(s0)
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	49e080e7          	jalr	1182(ra) # 80003c88 <fileread>
    800047f2:	87aa                	mv	a5,a0
}
    800047f4:	853e                	mv	a0,a5
    800047f6:	70a2                	ld	ra,40(sp)
    800047f8:	7402                	ld	s0,32(sp)
    800047fa:	6145                	addi	sp,sp,48
    800047fc:	8082                	ret

00000000800047fe <sys_write>:
{
    800047fe:	7179                	addi	sp,sp,-48
    80004800:	f406                	sd	ra,40(sp)
    80004802:	f022                	sd	s0,32(sp)
    80004804:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004806:	fe840613          	addi	a2,s0,-24
    8000480a:	4581                	li	a1,0
    8000480c:	4501                	li	a0,0
    8000480e:	00000097          	auipc	ra,0x0
    80004812:	d2a080e7          	jalr	-726(ra) # 80004538 <argfd>
    return -1;
    80004816:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004818:	04054163          	bltz	a0,8000485a <sys_write+0x5c>
    8000481c:	fe440593          	addi	a1,s0,-28
    80004820:	4509                	li	a0,2
    80004822:	ffffe097          	auipc	ra,0xffffe
    80004826:	91c080e7          	jalr	-1764(ra) # 8000213e <argint>
    return -1;
    8000482a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000482c:	02054763          	bltz	a0,8000485a <sys_write+0x5c>
    80004830:	fd840593          	addi	a1,s0,-40
    80004834:	4505                	li	a0,1
    80004836:	ffffe097          	auipc	ra,0xffffe
    8000483a:	92a080e7          	jalr	-1750(ra) # 80002160 <argaddr>
    return -1;
    8000483e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004840:	00054d63          	bltz	a0,8000485a <sys_write+0x5c>
  return filewrite(f, p, n);
    80004844:	fe442603          	lw	a2,-28(s0)
    80004848:	fd843583          	ld	a1,-40(s0)
    8000484c:	fe843503          	ld	a0,-24(s0)
    80004850:	fffff097          	auipc	ra,0xfffff
    80004854:	4fa080e7          	jalr	1274(ra) # 80003d4a <filewrite>
    80004858:	87aa                	mv	a5,a0
}
    8000485a:	853e                	mv	a0,a5
    8000485c:	70a2                	ld	ra,40(sp)
    8000485e:	7402                	ld	s0,32(sp)
    80004860:	6145                	addi	sp,sp,48
    80004862:	8082                	ret

0000000080004864 <sys_close>:
{
    80004864:	1101                	addi	sp,sp,-32
    80004866:	ec06                	sd	ra,24(sp)
    80004868:	e822                	sd	s0,16(sp)
    8000486a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000486c:	fe040613          	addi	a2,s0,-32
    80004870:	fec40593          	addi	a1,s0,-20
    80004874:	4501                	li	a0,0
    80004876:	00000097          	auipc	ra,0x0
    8000487a:	cc2080e7          	jalr	-830(ra) # 80004538 <argfd>
    return -1;
    8000487e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004880:	02054463          	bltz	a0,800048a8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004884:	ffffc097          	auipc	ra,0xffffc
    80004888:	748080e7          	jalr	1864(ra) # 80000fcc <myproc>
    8000488c:	fec42783          	lw	a5,-20(s0)
    80004890:	07e9                	addi	a5,a5,26
    80004892:	078e                	slli	a5,a5,0x3
    80004894:	97aa                	add	a5,a5,a0
    80004896:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000489a:	fe043503          	ld	a0,-32(s0)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	2b0080e7          	jalr	688(ra) # 80003b4e <fileclose>
  return 0;
    800048a6:	4781                	li	a5,0
}
    800048a8:	853e                	mv	a0,a5
    800048aa:	60e2                	ld	ra,24(sp)
    800048ac:	6442                	ld	s0,16(sp)
    800048ae:	6105                	addi	sp,sp,32
    800048b0:	8082                	ret

00000000800048b2 <sys_fstat>:
{
    800048b2:	1101                	addi	sp,sp,-32
    800048b4:	ec06                	sd	ra,24(sp)
    800048b6:	e822                	sd	s0,16(sp)
    800048b8:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048ba:	fe840613          	addi	a2,s0,-24
    800048be:	4581                	li	a1,0
    800048c0:	4501                	li	a0,0
    800048c2:	00000097          	auipc	ra,0x0
    800048c6:	c76080e7          	jalr	-906(ra) # 80004538 <argfd>
    return -1;
    800048ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048cc:	02054563          	bltz	a0,800048f6 <sys_fstat+0x44>
    800048d0:	fe040593          	addi	a1,s0,-32
    800048d4:	4505                	li	a0,1
    800048d6:	ffffe097          	auipc	ra,0xffffe
    800048da:	88a080e7          	jalr	-1910(ra) # 80002160 <argaddr>
    return -1;
    800048de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048e0:	00054b63          	bltz	a0,800048f6 <sys_fstat+0x44>
  return filestat(f, st);
    800048e4:	fe043583          	ld	a1,-32(s0)
    800048e8:	fe843503          	ld	a0,-24(s0)
    800048ec:	fffff097          	auipc	ra,0xfffff
    800048f0:	32a080e7          	jalr	810(ra) # 80003c16 <filestat>
    800048f4:	87aa                	mv	a5,a0
}
    800048f6:	853e                	mv	a0,a5
    800048f8:	60e2                	ld	ra,24(sp)
    800048fa:	6442                	ld	s0,16(sp)
    800048fc:	6105                	addi	sp,sp,32
    800048fe:	8082                	ret

0000000080004900 <sys_link>:
{
    80004900:	7169                	addi	sp,sp,-304
    80004902:	f606                	sd	ra,296(sp)
    80004904:	f222                	sd	s0,288(sp)
    80004906:	ee26                	sd	s1,280(sp)
    80004908:	ea4a                	sd	s2,272(sp)
    8000490a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000490c:	08000613          	li	a2,128
    80004910:	ed040593          	addi	a1,s0,-304
    80004914:	4501                	li	a0,0
    80004916:	ffffe097          	auipc	ra,0xffffe
    8000491a:	86c080e7          	jalr	-1940(ra) # 80002182 <argstr>
    return -1;
    8000491e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004920:	10054e63          	bltz	a0,80004a3c <sys_link+0x13c>
    80004924:	08000613          	li	a2,128
    80004928:	f5040593          	addi	a1,s0,-176
    8000492c:	4505                	li	a0,1
    8000492e:	ffffe097          	auipc	ra,0xffffe
    80004932:	854080e7          	jalr	-1964(ra) # 80002182 <argstr>
    return -1;
    80004936:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004938:	10054263          	bltz	a0,80004a3c <sys_link+0x13c>
  begin_op();
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	d46080e7          	jalr	-698(ra) # 80003682 <begin_op>
  if((ip = namei(old)) == 0){
    80004944:	ed040513          	addi	a0,s0,-304
    80004948:	fffff097          	auipc	ra,0xfffff
    8000494c:	b1e080e7          	jalr	-1250(ra) # 80003466 <namei>
    80004950:	84aa                	mv	s1,a0
    80004952:	c551                	beqz	a0,800049de <sys_link+0xde>
  ilock(ip);
    80004954:	ffffe097          	auipc	ra,0xffffe
    80004958:	35c080e7          	jalr	860(ra) # 80002cb0 <ilock>
  if(ip->type == T_DIR){
    8000495c:	04449703          	lh	a4,68(s1)
    80004960:	4785                	li	a5,1
    80004962:	08f70463          	beq	a4,a5,800049ea <sys_link+0xea>
  ip->nlink++;
    80004966:	04a4d783          	lhu	a5,74(s1)
    8000496a:	2785                	addiw	a5,a5,1
    8000496c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004970:	8526                	mv	a0,s1
    80004972:	ffffe097          	auipc	ra,0xffffe
    80004976:	274080e7          	jalr	628(ra) # 80002be6 <iupdate>
  iunlock(ip);
    8000497a:	8526                	mv	a0,s1
    8000497c:	ffffe097          	auipc	ra,0xffffe
    80004980:	3f6080e7          	jalr	1014(ra) # 80002d72 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004984:	fd040593          	addi	a1,s0,-48
    80004988:	f5040513          	addi	a0,s0,-176
    8000498c:	fffff097          	auipc	ra,0xfffff
    80004990:	af8080e7          	jalr	-1288(ra) # 80003484 <nameiparent>
    80004994:	892a                	mv	s2,a0
    80004996:	c935                	beqz	a0,80004a0a <sys_link+0x10a>
  ilock(dp);
    80004998:	ffffe097          	auipc	ra,0xffffe
    8000499c:	318080e7          	jalr	792(ra) # 80002cb0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800049a0:	00092703          	lw	a4,0(s2)
    800049a4:	409c                	lw	a5,0(s1)
    800049a6:	04f71d63          	bne	a4,a5,80004a00 <sys_link+0x100>
    800049aa:	40d0                	lw	a2,4(s1)
    800049ac:	fd040593          	addi	a1,s0,-48
    800049b0:	854a                	mv	a0,s2
    800049b2:	fffff097          	auipc	ra,0xfffff
    800049b6:	9f2080e7          	jalr	-1550(ra) # 800033a4 <dirlink>
    800049ba:	04054363          	bltz	a0,80004a00 <sys_link+0x100>
  iunlockput(dp);
    800049be:	854a                	mv	a0,s2
    800049c0:	ffffe097          	auipc	ra,0xffffe
    800049c4:	552080e7          	jalr	1362(ra) # 80002f12 <iunlockput>
  iput(ip);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffe097          	auipc	ra,0xffffe
    800049ce:	4a0080e7          	jalr	1184(ra) # 80002e6a <iput>
  end_op();
    800049d2:	fffff097          	auipc	ra,0xfffff
    800049d6:	d30080e7          	jalr	-720(ra) # 80003702 <end_op>
  return 0;
    800049da:	4781                	li	a5,0
    800049dc:	a085                	j	80004a3c <sys_link+0x13c>
    end_op();
    800049de:	fffff097          	auipc	ra,0xfffff
    800049e2:	d24080e7          	jalr	-732(ra) # 80003702 <end_op>
    return -1;
    800049e6:	57fd                	li	a5,-1
    800049e8:	a891                	j	80004a3c <sys_link+0x13c>
    iunlockput(ip);
    800049ea:	8526                	mv	a0,s1
    800049ec:	ffffe097          	auipc	ra,0xffffe
    800049f0:	526080e7          	jalr	1318(ra) # 80002f12 <iunlockput>
    end_op();
    800049f4:	fffff097          	auipc	ra,0xfffff
    800049f8:	d0e080e7          	jalr	-754(ra) # 80003702 <end_op>
    return -1;
    800049fc:	57fd                	li	a5,-1
    800049fe:	a83d                	j	80004a3c <sys_link+0x13c>
    iunlockput(dp);
    80004a00:	854a                	mv	a0,s2
    80004a02:	ffffe097          	auipc	ra,0xffffe
    80004a06:	510080e7          	jalr	1296(ra) # 80002f12 <iunlockput>
  ilock(ip);
    80004a0a:	8526                	mv	a0,s1
    80004a0c:	ffffe097          	auipc	ra,0xffffe
    80004a10:	2a4080e7          	jalr	676(ra) # 80002cb0 <ilock>
  ip->nlink--;
    80004a14:	04a4d783          	lhu	a5,74(s1)
    80004a18:	37fd                	addiw	a5,a5,-1
    80004a1a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffe097          	auipc	ra,0xffffe
    80004a24:	1c6080e7          	jalr	454(ra) # 80002be6 <iupdate>
  iunlockput(ip);
    80004a28:	8526                	mv	a0,s1
    80004a2a:	ffffe097          	auipc	ra,0xffffe
    80004a2e:	4e8080e7          	jalr	1256(ra) # 80002f12 <iunlockput>
  end_op();
    80004a32:	fffff097          	auipc	ra,0xfffff
    80004a36:	cd0080e7          	jalr	-816(ra) # 80003702 <end_op>
  return -1;
    80004a3a:	57fd                	li	a5,-1
}
    80004a3c:	853e                	mv	a0,a5
    80004a3e:	70b2                	ld	ra,296(sp)
    80004a40:	7412                	ld	s0,288(sp)
    80004a42:	64f2                	ld	s1,280(sp)
    80004a44:	6952                	ld	s2,272(sp)
    80004a46:	6155                	addi	sp,sp,304
    80004a48:	8082                	ret

0000000080004a4a <sys_unlink>:
{
    80004a4a:	7151                	addi	sp,sp,-240
    80004a4c:	f586                	sd	ra,232(sp)
    80004a4e:	f1a2                	sd	s0,224(sp)
    80004a50:	eda6                	sd	s1,216(sp)
    80004a52:	e9ca                	sd	s2,208(sp)
    80004a54:	e5ce                	sd	s3,200(sp)
    80004a56:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004a58:	08000613          	li	a2,128
    80004a5c:	f3040593          	addi	a1,s0,-208
    80004a60:	4501                	li	a0,0
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	720080e7          	jalr	1824(ra) # 80002182 <argstr>
    80004a6a:	18054163          	bltz	a0,80004bec <sys_unlink+0x1a2>
  begin_op();
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	c14080e7          	jalr	-1004(ra) # 80003682 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004a76:	fb040593          	addi	a1,s0,-80
    80004a7a:	f3040513          	addi	a0,s0,-208
    80004a7e:	fffff097          	auipc	ra,0xfffff
    80004a82:	a06080e7          	jalr	-1530(ra) # 80003484 <nameiparent>
    80004a86:	84aa                	mv	s1,a0
    80004a88:	c979                	beqz	a0,80004b5e <sys_unlink+0x114>
  ilock(dp);
    80004a8a:	ffffe097          	auipc	ra,0xffffe
    80004a8e:	226080e7          	jalr	550(ra) # 80002cb0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a92:	00004597          	auipc	a1,0x4
    80004a96:	c3e58593          	addi	a1,a1,-962 # 800086d0 <syscalls+0x2b0>
    80004a9a:	fb040513          	addi	a0,s0,-80
    80004a9e:	ffffe097          	auipc	ra,0xffffe
    80004aa2:	6dc080e7          	jalr	1756(ra) # 8000317a <namecmp>
    80004aa6:	14050a63          	beqz	a0,80004bfa <sys_unlink+0x1b0>
    80004aaa:	00004597          	auipc	a1,0x4
    80004aae:	c2e58593          	addi	a1,a1,-978 # 800086d8 <syscalls+0x2b8>
    80004ab2:	fb040513          	addi	a0,s0,-80
    80004ab6:	ffffe097          	auipc	ra,0xffffe
    80004aba:	6c4080e7          	jalr	1732(ra) # 8000317a <namecmp>
    80004abe:	12050e63          	beqz	a0,80004bfa <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004ac2:	f2c40613          	addi	a2,s0,-212
    80004ac6:	fb040593          	addi	a1,s0,-80
    80004aca:	8526                	mv	a0,s1
    80004acc:	ffffe097          	auipc	ra,0xffffe
    80004ad0:	6c8080e7          	jalr	1736(ra) # 80003194 <dirlookup>
    80004ad4:	892a                	mv	s2,a0
    80004ad6:	12050263          	beqz	a0,80004bfa <sys_unlink+0x1b0>
  ilock(ip);
    80004ada:	ffffe097          	auipc	ra,0xffffe
    80004ade:	1d6080e7          	jalr	470(ra) # 80002cb0 <ilock>
  if(ip->nlink < 1)
    80004ae2:	04a91783          	lh	a5,74(s2)
    80004ae6:	08f05263          	blez	a5,80004b6a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004aea:	04491703          	lh	a4,68(s2)
    80004aee:	4785                	li	a5,1
    80004af0:	08f70563          	beq	a4,a5,80004b7a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004af4:	4641                	li	a2,16
    80004af6:	4581                	li	a1,0
    80004af8:	fc040513          	addi	a0,s0,-64
    80004afc:	ffffb097          	auipc	ra,0xffffb
    80004b00:	7b8080e7          	jalr	1976(ra) # 800002b4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b04:	4741                	li	a4,16
    80004b06:	f2c42683          	lw	a3,-212(s0)
    80004b0a:	fc040613          	addi	a2,s0,-64
    80004b0e:	4581                	li	a1,0
    80004b10:	8526                	mv	a0,s1
    80004b12:	ffffe097          	auipc	ra,0xffffe
    80004b16:	54a080e7          	jalr	1354(ra) # 8000305c <writei>
    80004b1a:	47c1                	li	a5,16
    80004b1c:	0af51563          	bne	a0,a5,80004bc6 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004b20:	04491703          	lh	a4,68(s2)
    80004b24:	4785                	li	a5,1
    80004b26:	0af70863          	beq	a4,a5,80004bd6 <sys_unlink+0x18c>
  iunlockput(dp);
    80004b2a:	8526                	mv	a0,s1
    80004b2c:	ffffe097          	auipc	ra,0xffffe
    80004b30:	3e6080e7          	jalr	998(ra) # 80002f12 <iunlockput>
  ip->nlink--;
    80004b34:	04a95783          	lhu	a5,74(s2)
    80004b38:	37fd                	addiw	a5,a5,-1
    80004b3a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b3e:	854a                	mv	a0,s2
    80004b40:	ffffe097          	auipc	ra,0xffffe
    80004b44:	0a6080e7          	jalr	166(ra) # 80002be6 <iupdate>
  iunlockput(ip);
    80004b48:	854a                	mv	a0,s2
    80004b4a:	ffffe097          	auipc	ra,0xffffe
    80004b4e:	3c8080e7          	jalr	968(ra) # 80002f12 <iunlockput>
  end_op();
    80004b52:	fffff097          	auipc	ra,0xfffff
    80004b56:	bb0080e7          	jalr	-1104(ra) # 80003702 <end_op>
  return 0;
    80004b5a:	4501                	li	a0,0
    80004b5c:	a84d                	j	80004c0e <sys_unlink+0x1c4>
    end_op();
    80004b5e:	fffff097          	auipc	ra,0xfffff
    80004b62:	ba4080e7          	jalr	-1116(ra) # 80003702 <end_op>
    return -1;
    80004b66:	557d                	li	a0,-1
    80004b68:	a05d                	j	80004c0e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004b6a:	00004517          	auipc	a0,0x4
    80004b6e:	b9650513          	addi	a0,a0,-1130 # 80008700 <syscalls+0x2e0>
    80004b72:	00001097          	auipc	ra,0x1
    80004b76:	1f6080e7          	jalr	502(ra) # 80005d68 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b7a:	04c92703          	lw	a4,76(s2)
    80004b7e:	02000793          	li	a5,32
    80004b82:	f6e7f9e3          	bgeu	a5,a4,80004af4 <sys_unlink+0xaa>
    80004b86:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b8a:	4741                	li	a4,16
    80004b8c:	86ce                	mv	a3,s3
    80004b8e:	f1840613          	addi	a2,s0,-232
    80004b92:	4581                	li	a1,0
    80004b94:	854a                	mv	a0,s2
    80004b96:	ffffe097          	auipc	ra,0xffffe
    80004b9a:	3ce080e7          	jalr	974(ra) # 80002f64 <readi>
    80004b9e:	47c1                	li	a5,16
    80004ba0:	00f51b63          	bne	a0,a5,80004bb6 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004ba4:	f1845783          	lhu	a5,-232(s0)
    80004ba8:	e7a1                	bnez	a5,80004bf0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004baa:	29c1                	addiw	s3,s3,16
    80004bac:	04c92783          	lw	a5,76(s2)
    80004bb0:	fcf9ede3          	bltu	s3,a5,80004b8a <sys_unlink+0x140>
    80004bb4:	b781                	j	80004af4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004bb6:	00004517          	auipc	a0,0x4
    80004bba:	b6250513          	addi	a0,a0,-1182 # 80008718 <syscalls+0x2f8>
    80004bbe:	00001097          	auipc	ra,0x1
    80004bc2:	1aa080e7          	jalr	426(ra) # 80005d68 <panic>
    panic("unlink: writei");
    80004bc6:	00004517          	auipc	a0,0x4
    80004bca:	b6a50513          	addi	a0,a0,-1174 # 80008730 <syscalls+0x310>
    80004bce:	00001097          	auipc	ra,0x1
    80004bd2:	19a080e7          	jalr	410(ra) # 80005d68 <panic>
    dp->nlink--;
    80004bd6:	04a4d783          	lhu	a5,74(s1)
    80004bda:	37fd                	addiw	a5,a5,-1
    80004bdc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004be0:	8526                	mv	a0,s1
    80004be2:	ffffe097          	auipc	ra,0xffffe
    80004be6:	004080e7          	jalr	4(ra) # 80002be6 <iupdate>
    80004bea:	b781                	j	80004b2a <sys_unlink+0xe0>
    return -1;
    80004bec:	557d                	li	a0,-1
    80004bee:	a005                	j	80004c0e <sys_unlink+0x1c4>
    iunlockput(ip);
    80004bf0:	854a                	mv	a0,s2
    80004bf2:	ffffe097          	auipc	ra,0xffffe
    80004bf6:	320080e7          	jalr	800(ra) # 80002f12 <iunlockput>
  iunlockput(dp);
    80004bfa:	8526                	mv	a0,s1
    80004bfc:	ffffe097          	auipc	ra,0xffffe
    80004c00:	316080e7          	jalr	790(ra) # 80002f12 <iunlockput>
  end_op();
    80004c04:	fffff097          	auipc	ra,0xfffff
    80004c08:	afe080e7          	jalr	-1282(ra) # 80003702 <end_op>
  return -1;
    80004c0c:	557d                	li	a0,-1
}
    80004c0e:	70ae                	ld	ra,232(sp)
    80004c10:	740e                	ld	s0,224(sp)
    80004c12:	64ee                	ld	s1,216(sp)
    80004c14:	694e                	ld	s2,208(sp)
    80004c16:	69ae                	ld	s3,200(sp)
    80004c18:	616d                	addi	sp,sp,240
    80004c1a:	8082                	ret

0000000080004c1c <sys_open>:

uint64
sys_open(void)
{
    80004c1c:	7131                	addi	sp,sp,-192
    80004c1e:	fd06                	sd	ra,184(sp)
    80004c20:	f922                	sd	s0,176(sp)
    80004c22:	f526                	sd	s1,168(sp)
    80004c24:	f14a                	sd	s2,160(sp)
    80004c26:	ed4e                	sd	s3,152(sp)
    80004c28:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004c2a:	08000613          	li	a2,128
    80004c2e:	f5040593          	addi	a1,s0,-176
    80004c32:	4501                	li	a0,0
    80004c34:	ffffd097          	auipc	ra,0xffffd
    80004c38:	54e080e7          	jalr	1358(ra) # 80002182 <argstr>
    return -1;
    80004c3c:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004c3e:	0c054163          	bltz	a0,80004d00 <sys_open+0xe4>
    80004c42:	f4c40593          	addi	a1,s0,-180
    80004c46:	4505                	li	a0,1
    80004c48:	ffffd097          	auipc	ra,0xffffd
    80004c4c:	4f6080e7          	jalr	1270(ra) # 8000213e <argint>
    80004c50:	0a054863          	bltz	a0,80004d00 <sys_open+0xe4>

  begin_op();
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	a2e080e7          	jalr	-1490(ra) # 80003682 <begin_op>

  if(omode & O_CREATE){
    80004c5c:	f4c42783          	lw	a5,-180(s0)
    80004c60:	2007f793          	andi	a5,a5,512
    80004c64:	cbdd                	beqz	a5,80004d1a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004c66:	4681                	li	a3,0
    80004c68:	4601                	li	a2,0
    80004c6a:	4589                	li	a1,2
    80004c6c:	f5040513          	addi	a0,s0,-176
    80004c70:	00000097          	auipc	ra,0x0
    80004c74:	972080e7          	jalr	-1678(ra) # 800045e2 <create>
    80004c78:	892a                	mv	s2,a0
    if(ip == 0){
    80004c7a:	c959                	beqz	a0,80004d10 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c7c:	04491703          	lh	a4,68(s2)
    80004c80:	478d                	li	a5,3
    80004c82:	00f71763          	bne	a4,a5,80004c90 <sys_open+0x74>
    80004c86:	04695703          	lhu	a4,70(s2)
    80004c8a:	47a5                	li	a5,9
    80004c8c:	0ce7ec63          	bltu	a5,a4,80004d64 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c90:	fffff097          	auipc	ra,0xfffff
    80004c94:	e02080e7          	jalr	-510(ra) # 80003a92 <filealloc>
    80004c98:	89aa                	mv	s3,a0
    80004c9a:	10050263          	beqz	a0,80004d9e <sys_open+0x182>
    80004c9e:	00000097          	auipc	ra,0x0
    80004ca2:	902080e7          	jalr	-1790(ra) # 800045a0 <fdalloc>
    80004ca6:	84aa                	mv	s1,a0
    80004ca8:	0e054663          	bltz	a0,80004d94 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004cac:	04491703          	lh	a4,68(s2)
    80004cb0:	478d                	li	a5,3
    80004cb2:	0cf70463          	beq	a4,a5,80004d7a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004cb6:	4789                	li	a5,2
    80004cb8:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004cbc:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004cc0:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004cc4:	f4c42783          	lw	a5,-180(s0)
    80004cc8:	0017c713          	xori	a4,a5,1
    80004ccc:	8b05                	andi	a4,a4,1
    80004cce:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004cd2:	0037f713          	andi	a4,a5,3
    80004cd6:	00e03733          	snez	a4,a4
    80004cda:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004cde:	4007f793          	andi	a5,a5,1024
    80004ce2:	c791                	beqz	a5,80004cee <sys_open+0xd2>
    80004ce4:	04491703          	lh	a4,68(s2)
    80004ce8:	4789                	li	a5,2
    80004cea:	08f70f63          	beq	a4,a5,80004d88 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004cee:	854a                	mv	a0,s2
    80004cf0:	ffffe097          	auipc	ra,0xffffe
    80004cf4:	082080e7          	jalr	130(ra) # 80002d72 <iunlock>
  end_op();
    80004cf8:	fffff097          	auipc	ra,0xfffff
    80004cfc:	a0a080e7          	jalr	-1526(ra) # 80003702 <end_op>

  return fd;
}
    80004d00:	8526                	mv	a0,s1
    80004d02:	70ea                	ld	ra,184(sp)
    80004d04:	744a                	ld	s0,176(sp)
    80004d06:	74aa                	ld	s1,168(sp)
    80004d08:	790a                	ld	s2,160(sp)
    80004d0a:	69ea                	ld	s3,152(sp)
    80004d0c:	6129                	addi	sp,sp,192
    80004d0e:	8082                	ret
      end_op();
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	9f2080e7          	jalr	-1550(ra) # 80003702 <end_op>
      return -1;
    80004d18:	b7e5                	j	80004d00 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004d1a:	f5040513          	addi	a0,s0,-176
    80004d1e:	ffffe097          	auipc	ra,0xffffe
    80004d22:	748080e7          	jalr	1864(ra) # 80003466 <namei>
    80004d26:	892a                	mv	s2,a0
    80004d28:	c905                	beqz	a0,80004d58 <sys_open+0x13c>
    ilock(ip);
    80004d2a:	ffffe097          	auipc	ra,0xffffe
    80004d2e:	f86080e7          	jalr	-122(ra) # 80002cb0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004d32:	04491703          	lh	a4,68(s2)
    80004d36:	4785                	li	a5,1
    80004d38:	f4f712e3          	bne	a4,a5,80004c7c <sys_open+0x60>
    80004d3c:	f4c42783          	lw	a5,-180(s0)
    80004d40:	dba1                	beqz	a5,80004c90 <sys_open+0x74>
      iunlockput(ip);
    80004d42:	854a                	mv	a0,s2
    80004d44:	ffffe097          	auipc	ra,0xffffe
    80004d48:	1ce080e7          	jalr	462(ra) # 80002f12 <iunlockput>
      end_op();
    80004d4c:	fffff097          	auipc	ra,0xfffff
    80004d50:	9b6080e7          	jalr	-1610(ra) # 80003702 <end_op>
      return -1;
    80004d54:	54fd                	li	s1,-1
    80004d56:	b76d                	j	80004d00 <sys_open+0xe4>
      end_op();
    80004d58:	fffff097          	auipc	ra,0xfffff
    80004d5c:	9aa080e7          	jalr	-1622(ra) # 80003702 <end_op>
      return -1;
    80004d60:	54fd                	li	s1,-1
    80004d62:	bf79                	j	80004d00 <sys_open+0xe4>
    iunlockput(ip);
    80004d64:	854a                	mv	a0,s2
    80004d66:	ffffe097          	auipc	ra,0xffffe
    80004d6a:	1ac080e7          	jalr	428(ra) # 80002f12 <iunlockput>
    end_op();
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	994080e7          	jalr	-1644(ra) # 80003702 <end_op>
    return -1;
    80004d76:	54fd                	li	s1,-1
    80004d78:	b761                	j	80004d00 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004d7a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d7e:	04691783          	lh	a5,70(s2)
    80004d82:	02f99223          	sh	a5,36(s3)
    80004d86:	bf2d                	j	80004cc0 <sys_open+0xa4>
    itrunc(ip);
    80004d88:	854a                	mv	a0,s2
    80004d8a:	ffffe097          	auipc	ra,0xffffe
    80004d8e:	034080e7          	jalr	52(ra) # 80002dbe <itrunc>
    80004d92:	bfb1                	j	80004cee <sys_open+0xd2>
      fileclose(f);
    80004d94:	854e                	mv	a0,s3
    80004d96:	fffff097          	auipc	ra,0xfffff
    80004d9a:	db8080e7          	jalr	-584(ra) # 80003b4e <fileclose>
    iunlockput(ip);
    80004d9e:	854a                	mv	a0,s2
    80004da0:	ffffe097          	auipc	ra,0xffffe
    80004da4:	172080e7          	jalr	370(ra) # 80002f12 <iunlockput>
    end_op();
    80004da8:	fffff097          	auipc	ra,0xfffff
    80004dac:	95a080e7          	jalr	-1702(ra) # 80003702 <end_op>
    return -1;
    80004db0:	54fd                	li	s1,-1
    80004db2:	b7b9                	j	80004d00 <sys_open+0xe4>

0000000080004db4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004db4:	7175                	addi	sp,sp,-144
    80004db6:	e506                	sd	ra,136(sp)
    80004db8:	e122                	sd	s0,128(sp)
    80004dba:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	8c6080e7          	jalr	-1850(ra) # 80003682 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004dc4:	08000613          	li	a2,128
    80004dc8:	f7040593          	addi	a1,s0,-144
    80004dcc:	4501                	li	a0,0
    80004dce:	ffffd097          	auipc	ra,0xffffd
    80004dd2:	3b4080e7          	jalr	948(ra) # 80002182 <argstr>
    80004dd6:	02054963          	bltz	a0,80004e08 <sys_mkdir+0x54>
    80004dda:	4681                	li	a3,0
    80004ddc:	4601                	li	a2,0
    80004dde:	4585                	li	a1,1
    80004de0:	f7040513          	addi	a0,s0,-144
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	7fe080e7          	jalr	2046(ra) # 800045e2 <create>
    80004dec:	cd11                	beqz	a0,80004e08 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004dee:	ffffe097          	auipc	ra,0xffffe
    80004df2:	124080e7          	jalr	292(ra) # 80002f12 <iunlockput>
  end_op();
    80004df6:	fffff097          	auipc	ra,0xfffff
    80004dfa:	90c080e7          	jalr	-1780(ra) # 80003702 <end_op>
  return 0;
    80004dfe:	4501                	li	a0,0
}
    80004e00:	60aa                	ld	ra,136(sp)
    80004e02:	640a                	ld	s0,128(sp)
    80004e04:	6149                	addi	sp,sp,144
    80004e06:	8082                	ret
    end_op();
    80004e08:	fffff097          	auipc	ra,0xfffff
    80004e0c:	8fa080e7          	jalr	-1798(ra) # 80003702 <end_op>
    return -1;
    80004e10:	557d                	li	a0,-1
    80004e12:	b7fd                	j	80004e00 <sys_mkdir+0x4c>

0000000080004e14 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004e14:	7135                	addi	sp,sp,-160
    80004e16:	ed06                	sd	ra,152(sp)
    80004e18:	e922                	sd	s0,144(sp)
    80004e1a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004e1c:	fffff097          	auipc	ra,0xfffff
    80004e20:	866080e7          	jalr	-1946(ra) # 80003682 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e24:	08000613          	li	a2,128
    80004e28:	f7040593          	addi	a1,s0,-144
    80004e2c:	4501                	li	a0,0
    80004e2e:	ffffd097          	auipc	ra,0xffffd
    80004e32:	354080e7          	jalr	852(ra) # 80002182 <argstr>
    80004e36:	04054a63          	bltz	a0,80004e8a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80004e3a:	f6c40593          	addi	a1,s0,-148
    80004e3e:	4505                	li	a0,1
    80004e40:	ffffd097          	auipc	ra,0xffffd
    80004e44:	2fe080e7          	jalr	766(ra) # 8000213e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e48:	04054163          	bltz	a0,80004e8a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80004e4c:	f6840593          	addi	a1,s0,-152
    80004e50:	4509                	li	a0,2
    80004e52:	ffffd097          	auipc	ra,0xffffd
    80004e56:	2ec080e7          	jalr	748(ra) # 8000213e <argint>
     argint(1, &major) < 0 ||
    80004e5a:	02054863          	bltz	a0,80004e8a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004e5e:	f6841683          	lh	a3,-152(s0)
    80004e62:	f6c41603          	lh	a2,-148(s0)
    80004e66:	458d                	li	a1,3
    80004e68:	f7040513          	addi	a0,s0,-144
    80004e6c:	fffff097          	auipc	ra,0xfffff
    80004e70:	776080e7          	jalr	1910(ra) # 800045e2 <create>
     argint(2, &minor) < 0 ||
    80004e74:	c919                	beqz	a0,80004e8a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004e76:	ffffe097          	auipc	ra,0xffffe
    80004e7a:	09c080e7          	jalr	156(ra) # 80002f12 <iunlockput>
  end_op();
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	884080e7          	jalr	-1916(ra) # 80003702 <end_op>
  return 0;
    80004e86:	4501                	li	a0,0
    80004e88:	a031                	j	80004e94 <sys_mknod+0x80>
    end_op();
    80004e8a:	fffff097          	auipc	ra,0xfffff
    80004e8e:	878080e7          	jalr	-1928(ra) # 80003702 <end_op>
    return -1;
    80004e92:	557d                	li	a0,-1
}
    80004e94:	60ea                	ld	ra,152(sp)
    80004e96:	644a                	ld	s0,144(sp)
    80004e98:	610d                	addi	sp,sp,160
    80004e9a:	8082                	ret

0000000080004e9c <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e9c:	7135                	addi	sp,sp,-160
    80004e9e:	ed06                	sd	ra,152(sp)
    80004ea0:	e922                	sd	s0,144(sp)
    80004ea2:	e526                	sd	s1,136(sp)
    80004ea4:	e14a                	sd	s2,128(sp)
    80004ea6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004ea8:	ffffc097          	auipc	ra,0xffffc
    80004eac:	124080e7          	jalr	292(ra) # 80000fcc <myproc>
    80004eb0:	892a                	mv	s2,a0
  
  begin_op();
    80004eb2:	ffffe097          	auipc	ra,0xffffe
    80004eb6:	7d0080e7          	jalr	2000(ra) # 80003682 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004eba:	08000613          	li	a2,128
    80004ebe:	f6040593          	addi	a1,s0,-160
    80004ec2:	4501                	li	a0,0
    80004ec4:	ffffd097          	auipc	ra,0xffffd
    80004ec8:	2be080e7          	jalr	702(ra) # 80002182 <argstr>
    80004ecc:	04054b63          	bltz	a0,80004f22 <sys_chdir+0x86>
    80004ed0:	f6040513          	addi	a0,s0,-160
    80004ed4:	ffffe097          	auipc	ra,0xffffe
    80004ed8:	592080e7          	jalr	1426(ra) # 80003466 <namei>
    80004edc:	84aa                	mv	s1,a0
    80004ede:	c131                	beqz	a0,80004f22 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004ee0:	ffffe097          	auipc	ra,0xffffe
    80004ee4:	dd0080e7          	jalr	-560(ra) # 80002cb0 <ilock>
  if(ip->type != T_DIR){
    80004ee8:	04449703          	lh	a4,68(s1)
    80004eec:	4785                	li	a5,1
    80004eee:	04f71063          	bne	a4,a5,80004f2e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004ef2:	8526                	mv	a0,s1
    80004ef4:	ffffe097          	auipc	ra,0xffffe
    80004ef8:	e7e080e7          	jalr	-386(ra) # 80002d72 <iunlock>
  iput(p->cwd);
    80004efc:	15093503          	ld	a0,336(s2)
    80004f00:	ffffe097          	auipc	ra,0xffffe
    80004f04:	f6a080e7          	jalr	-150(ra) # 80002e6a <iput>
  end_op();
    80004f08:	ffffe097          	auipc	ra,0xffffe
    80004f0c:	7fa080e7          	jalr	2042(ra) # 80003702 <end_op>
  p->cwd = ip;
    80004f10:	14993823          	sd	s1,336(s2)
  return 0;
    80004f14:	4501                	li	a0,0
}
    80004f16:	60ea                	ld	ra,152(sp)
    80004f18:	644a                	ld	s0,144(sp)
    80004f1a:	64aa                	ld	s1,136(sp)
    80004f1c:	690a                	ld	s2,128(sp)
    80004f1e:	610d                	addi	sp,sp,160
    80004f20:	8082                	ret
    end_op();
    80004f22:	ffffe097          	auipc	ra,0xffffe
    80004f26:	7e0080e7          	jalr	2016(ra) # 80003702 <end_op>
    return -1;
    80004f2a:	557d                	li	a0,-1
    80004f2c:	b7ed                	j	80004f16 <sys_chdir+0x7a>
    iunlockput(ip);
    80004f2e:	8526                	mv	a0,s1
    80004f30:	ffffe097          	auipc	ra,0xffffe
    80004f34:	fe2080e7          	jalr	-30(ra) # 80002f12 <iunlockput>
    end_op();
    80004f38:	ffffe097          	auipc	ra,0xffffe
    80004f3c:	7ca080e7          	jalr	1994(ra) # 80003702 <end_op>
    return -1;
    80004f40:	557d                	li	a0,-1
    80004f42:	bfd1                	j	80004f16 <sys_chdir+0x7a>

0000000080004f44 <sys_exec>:

uint64
sys_exec(void)
{
    80004f44:	7145                	addi	sp,sp,-464
    80004f46:	e786                	sd	ra,456(sp)
    80004f48:	e3a2                	sd	s0,448(sp)
    80004f4a:	ff26                	sd	s1,440(sp)
    80004f4c:	fb4a                	sd	s2,432(sp)
    80004f4e:	f74e                	sd	s3,424(sp)
    80004f50:	f352                	sd	s4,416(sp)
    80004f52:	ef56                	sd	s5,408(sp)
    80004f54:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004f56:	08000613          	li	a2,128
    80004f5a:	f4040593          	addi	a1,s0,-192
    80004f5e:	4501                	li	a0,0
    80004f60:	ffffd097          	auipc	ra,0xffffd
    80004f64:	222080e7          	jalr	546(ra) # 80002182 <argstr>
    return -1;
    80004f68:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004f6a:	0c054a63          	bltz	a0,8000503e <sys_exec+0xfa>
    80004f6e:	e3840593          	addi	a1,s0,-456
    80004f72:	4505                	li	a0,1
    80004f74:	ffffd097          	auipc	ra,0xffffd
    80004f78:	1ec080e7          	jalr	492(ra) # 80002160 <argaddr>
    80004f7c:	0c054163          	bltz	a0,8000503e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80004f80:	10000613          	li	a2,256
    80004f84:	4581                	li	a1,0
    80004f86:	e4040513          	addi	a0,s0,-448
    80004f8a:	ffffb097          	auipc	ra,0xffffb
    80004f8e:	32a080e7          	jalr	810(ra) # 800002b4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004f92:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004f96:	89a6                	mv	s3,s1
    80004f98:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004f9a:	02000a13          	li	s4,32
    80004f9e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004fa2:	00391513          	slli	a0,s2,0x3
    80004fa6:	e3040593          	addi	a1,s0,-464
    80004faa:	e3843783          	ld	a5,-456(s0)
    80004fae:	953e                	add	a0,a0,a5
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	0f4080e7          	jalr	244(ra) # 800020a4 <fetchaddr>
    80004fb8:	02054a63          	bltz	a0,80004fec <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80004fbc:	e3043783          	ld	a5,-464(s0)
    80004fc0:	c3b9                	beqz	a5,80005006 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004fc2:	ffffb097          	auipc	ra,0xffffb
    80004fc6:	25c080e7          	jalr	604(ra) # 8000021e <kalloc>
    80004fca:	85aa                	mv	a1,a0
    80004fcc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004fd0:	cd11                	beqz	a0,80004fec <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004fd2:	6605                	lui	a2,0x1
    80004fd4:	e3043503          	ld	a0,-464(s0)
    80004fd8:	ffffd097          	auipc	ra,0xffffd
    80004fdc:	11e080e7          	jalr	286(ra) # 800020f6 <fetchstr>
    80004fe0:	00054663          	bltz	a0,80004fec <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80004fe4:	0905                	addi	s2,s2,1
    80004fe6:	09a1                	addi	s3,s3,8
    80004fe8:	fb491be3          	bne	s2,s4,80004f9e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fec:	10048913          	addi	s2,s1,256
    80004ff0:	6088                	ld	a0,0(s1)
    80004ff2:	c529                	beqz	a0,8000503c <sys_exec+0xf8>
    kfree(argv[i]);
    80004ff4:	ffffb097          	auipc	ra,0xffffb
    80004ff8:	028080e7          	jalr	40(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ffc:	04a1                	addi	s1,s1,8
    80004ffe:	ff2499e3          	bne	s1,s2,80004ff0 <sys_exec+0xac>
  return -1;
    80005002:	597d                	li	s2,-1
    80005004:	a82d                	j	8000503e <sys_exec+0xfa>
      argv[i] = 0;
    80005006:	0a8e                	slli	s5,s5,0x3
    80005008:	fc040793          	addi	a5,s0,-64
    8000500c:	9abe                	add	s5,s5,a5
    8000500e:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005012:	e4040593          	addi	a1,s0,-448
    80005016:	f4040513          	addi	a0,s0,-192
    8000501a:	fffff097          	auipc	ra,0xfffff
    8000501e:	194080e7          	jalr	404(ra) # 800041ae <exec>
    80005022:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005024:	10048993          	addi	s3,s1,256
    80005028:	6088                	ld	a0,0(s1)
    8000502a:	c911                	beqz	a0,8000503e <sys_exec+0xfa>
    kfree(argv[i]);
    8000502c:	ffffb097          	auipc	ra,0xffffb
    80005030:	ff0080e7          	jalr	-16(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005034:	04a1                	addi	s1,s1,8
    80005036:	ff3499e3          	bne	s1,s3,80005028 <sys_exec+0xe4>
    8000503a:	a011                	j	8000503e <sys_exec+0xfa>
  return -1;
    8000503c:	597d                	li	s2,-1
}
    8000503e:	854a                	mv	a0,s2
    80005040:	60be                	ld	ra,456(sp)
    80005042:	641e                	ld	s0,448(sp)
    80005044:	74fa                	ld	s1,440(sp)
    80005046:	795a                	ld	s2,432(sp)
    80005048:	79ba                	ld	s3,424(sp)
    8000504a:	7a1a                	ld	s4,416(sp)
    8000504c:	6afa                	ld	s5,408(sp)
    8000504e:	6179                	addi	sp,sp,464
    80005050:	8082                	ret

0000000080005052 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005052:	7139                	addi	sp,sp,-64
    80005054:	fc06                	sd	ra,56(sp)
    80005056:	f822                	sd	s0,48(sp)
    80005058:	f426                	sd	s1,40(sp)
    8000505a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	f70080e7          	jalr	-144(ra) # 80000fcc <myproc>
    80005064:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005066:	fd840593          	addi	a1,s0,-40
    8000506a:	4501                	li	a0,0
    8000506c:	ffffd097          	auipc	ra,0xffffd
    80005070:	0f4080e7          	jalr	244(ra) # 80002160 <argaddr>
    return -1;
    80005074:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005076:	0e054063          	bltz	a0,80005156 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000507a:	fc840593          	addi	a1,s0,-56
    8000507e:	fd040513          	addi	a0,s0,-48
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	dfc080e7          	jalr	-516(ra) # 80003e7e <pipealloc>
    return -1;
    8000508a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000508c:	0c054563          	bltz	a0,80005156 <sys_pipe+0x104>
  fd0 = -1;
    80005090:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005094:	fd043503          	ld	a0,-48(s0)
    80005098:	fffff097          	auipc	ra,0xfffff
    8000509c:	508080e7          	jalr	1288(ra) # 800045a0 <fdalloc>
    800050a0:	fca42223          	sw	a0,-60(s0)
    800050a4:	08054c63          	bltz	a0,8000513c <sys_pipe+0xea>
    800050a8:	fc843503          	ld	a0,-56(s0)
    800050ac:	fffff097          	auipc	ra,0xfffff
    800050b0:	4f4080e7          	jalr	1268(ra) # 800045a0 <fdalloc>
    800050b4:	fca42023          	sw	a0,-64(s0)
    800050b8:	06054863          	bltz	a0,80005128 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050bc:	4691                	li	a3,4
    800050be:	fc440613          	addi	a2,s0,-60
    800050c2:	fd843583          	ld	a1,-40(s0)
    800050c6:	68a8                	ld	a0,80(s1)
    800050c8:	ffffc097          	auipc	ra,0xffffc
    800050cc:	b7a080e7          	jalr	-1158(ra) # 80000c42 <copyout>
    800050d0:	02054063          	bltz	a0,800050f0 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800050d4:	4691                	li	a3,4
    800050d6:	fc040613          	addi	a2,s0,-64
    800050da:	fd843583          	ld	a1,-40(s0)
    800050de:	0591                	addi	a1,a1,4
    800050e0:	68a8                	ld	a0,80(s1)
    800050e2:	ffffc097          	auipc	ra,0xffffc
    800050e6:	b60080e7          	jalr	-1184(ra) # 80000c42 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800050ea:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050ec:	06055563          	bgez	a0,80005156 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800050f0:	fc442783          	lw	a5,-60(s0)
    800050f4:	07e9                	addi	a5,a5,26
    800050f6:	078e                	slli	a5,a5,0x3
    800050f8:	97a6                	add	a5,a5,s1
    800050fa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800050fe:	fc042503          	lw	a0,-64(s0)
    80005102:	0569                	addi	a0,a0,26
    80005104:	050e                	slli	a0,a0,0x3
    80005106:	9526                	add	a0,a0,s1
    80005108:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000510c:	fd043503          	ld	a0,-48(s0)
    80005110:	fffff097          	auipc	ra,0xfffff
    80005114:	a3e080e7          	jalr	-1474(ra) # 80003b4e <fileclose>
    fileclose(wf);
    80005118:	fc843503          	ld	a0,-56(s0)
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	a32080e7          	jalr	-1486(ra) # 80003b4e <fileclose>
    return -1;
    80005124:	57fd                	li	a5,-1
    80005126:	a805                	j	80005156 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005128:	fc442783          	lw	a5,-60(s0)
    8000512c:	0007c863          	bltz	a5,8000513c <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005130:	01a78513          	addi	a0,a5,26
    80005134:	050e                	slli	a0,a0,0x3
    80005136:	9526                	add	a0,a0,s1
    80005138:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    8000513c:	fd043503          	ld	a0,-48(s0)
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	a0e080e7          	jalr	-1522(ra) # 80003b4e <fileclose>
    fileclose(wf);
    80005148:	fc843503          	ld	a0,-56(s0)
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	a02080e7          	jalr	-1534(ra) # 80003b4e <fileclose>
    return -1;
    80005154:	57fd                	li	a5,-1
}
    80005156:	853e                	mv	a0,a5
    80005158:	70e2                	ld	ra,56(sp)
    8000515a:	7442                	ld	s0,48(sp)
    8000515c:	74a2                	ld	s1,40(sp)
    8000515e:	6121                	addi	sp,sp,64
    80005160:	8082                	ret
	...

0000000080005170 <kernelvec>:
    80005170:	7111                	addi	sp,sp,-256
    80005172:	e006                	sd	ra,0(sp)
    80005174:	e40a                	sd	sp,8(sp)
    80005176:	e80e                	sd	gp,16(sp)
    80005178:	ec12                	sd	tp,24(sp)
    8000517a:	f016                	sd	t0,32(sp)
    8000517c:	f41a                	sd	t1,40(sp)
    8000517e:	f81e                	sd	t2,48(sp)
    80005180:	fc22                	sd	s0,56(sp)
    80005182:	e0a6                	sd	s1,64(sp)
    80005184:	e4aa                	sd	a0,72(sp)
    80005186:	e8ae                	sd	a1,80(sp)
    80005188:	ecb2                	sd	a2,88(sp)
    8000518a:	f0b6                	sd	a3,96(sp)
    8000518c:	f4ba                	sd	a4,104(sp)
    8000518e:	f8be                	sd	a5,112(sp)
    80005190:	fcc2                	sd	a6,120(sp)
    80005192:	e146                	sd	a7,128(sp)
    80005194:	e54a                	sd	s2,136(sp)
    80005196:	e94e                	sd	s3,144(sp)
    80005198:	ed52                	sd	s4,152(sp)
    8000519a:	f156                	sd	s5,160(sp)
    8000519c:	f55a                	sd	s6,168(sp)
    8000519e:	f95e                	sd	s7,176(sp)
    800051a0:	fd62                	sd	s8,184(sp)
    800051a2:	e1e6                	sd	s9,192(sp)
    800051a4:	e5ea                	sd	s10,200(sp)
    800051a6:	e9ee                	sd	s11,208(sp)
    800051a8:	edf2                	sd	t3,216(sp)
    800051aa:	f1f6                	sd	t4,224(sp)
    800051ac:	f5fa                	sd	t5,232(sp)
    800051ae:	f9fe                	sd	t6,240(sp)
    800051b0:	dc1fc0ef          	jal	ra,80001f70 <kerneltrap>
    800051b4:	6082                	ld	ra,0(sp)
    800051b6:	6122                	ld	sp,8(sp)
    800051b8:	61c2                	ld	gp,16(sp)
    800051ba:	7282                	ld	t0,32(sp)
    800051bc:	7322                	ld	t1,40(sp)
    800051be:	73c2                	ld	t2,48(sp)
    800051c0:	7462                	ld	s0,56(sp)
    800051c2:	6486                	ld	s1,64(sp)
    800051c4:	6526                	ld	a0,72(sp)
    800051c6:	65c6                	ld	a1,80(sp)
    800051c8:	6666                	ld	a2,88(sp)
    800051ca:	7686                	ld	a3,96(sp)
    800051cc:	7726                	ld	a4,104(sp)
    800051ce:	77c6                	ld	a5,112(sp)
    800051d0:	7866                	ld	a6,120(sp)
    800051d2:	688a                	ld	a7,128(sp)
    800051d4:	692a                	ld	s2,136(sp)
    800051d6:	69ca                	ld	s3,144(sp)
    800051d8:	6a6a                	ld	s4,152(sp)
    800051da:	7a8a                	ld	s5,160(sp)
    800051dc:	7b2a                	ld	s6,168(sp)
    800051de:	7bca                	ld	s7,176(sp)
    800051e0:	7c6a                	ld	s8,184(sp)
    800051e2:	6c8e                	ld	s9,192(sp)
    800051e4:	6d2e                	ld	s10,200(sp)
    800051e6:	6dce                	ld	s11,208(sp)
    800051e8:	6e6e                	ld	t3,216(sp)
    800051ea:	7e8e                	ld	t4,224(sp)
    800051ec:	7f2e                	ld	t5,232(sp)
    800051ee:	7fce                	ld	t6,240(sp)
    800051f0:	6111                	addi	sp,sp,256
    800051f2:	10200073          	sret
    800051f6:	00000013          	nop
    800051fa:	00000013          	nop
    800051fe:	0001                	nop

0000000080005200 <timervec>:
    80005200:	34051573          	csrrw	a0,mscratch,a0
    80005204:	e10c                	sd	a1,0(a0)
    80005206:	e510                	sd	a2,8(a0)
    80005208:	e914                	sd	a3,16(a0)
    8000520a:	6d0c                	ld	a1,24(a0)
    8000520c:	7110                	ld	a2,32(a0)
    8000520e:	6194                	ld	a3,0(a1)
    80005210:	96b2                	add	a3,a3,a2
    80005212:	e194                	sd	a3,0(a1)
    80005214:	4589                	li	a1,2
    80005216:	14459073          	csrw	sip,a1
    8000521a:	6914                	ld	a3,16(a0)
    8000521c:	6510                	ld	a2,8(a0)
    8000521e:	610c                	ld	a1,0(a0)
    80005220:	34051573          	csrrw	a0,mscratch,a0
    80005224:	30200073          	mret
	...

000000008000522a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000522a:	1141                	addi	sp,sp,-16
    8000522c:	e422                	sd	s0,8(sp)
    8000522e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005230:	0c0007b7          	lui	a5,0xc000
    80005234:	4705                	li	a4,1
    80005236:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005238:	c3d8                	sw	a4,4(a5)
}
    8000523a:	6422                	ld	s0,8(sp)
    8000523c:	0141                	addi	sp,sp,16
    8000523e:	8082                	ret

0000000080005240 <plicinithart>:

void
plicinithart(void)
{
    80005240:	1141                	addi	sp,sp,-16
    80005242:	e406                	sd	ra,8(sp)
    80005244:	e022                	sd	s0,0(sp)
    80005246:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	d58080e7          	jalr	-680(ra) # 80000fa0 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005250:	0085171b          	slliw	a4,a0,0x8
    80005254:	0c0027b7          	lui	a5,0xc002
    80005258:	97ba                	add	a5,a5,a4
    8000525a:	40200713          	li	a4,1026
    8000525e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005262:	00d5151b          	slliw	a0,a0,0xd
    80005266:	0c2017b7          	lui	a5,0xc201
    8000526a:	953e                	add	a0,a0,a5
    8000526c:	00052023          	sw	zero,0(a0)
}
    80005270:	60a2                	ld	ra,8(sp)
    80005272:	6402                	ld	s0,0(sp)
    80005274:	0141                	addi	sp,sp,16
    80005276:	8082                	ret

0000000080005278 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005278:	1141                	addi	sp,sp,-16
    8000527a:	e406                	sd	ra,8(sp)
    8000527c:	e022                	sd	s0,0(sp)
    8000527e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005280:	ffffc097          	auipc	ra,0xffffc
    80005284:	d20080e7          	jalr	-736(ra) # 80000fa0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005288:	00d5179b          	slliw	a5,a0,0xd
    8000528c:	0c201537          	lui	a0,0xc201
    80005290:	953e                	add	a0,a0,a5
  return irq;
}
    80005292:	4148                	lw	a0,4(a0)
    80005294:	60a2                	ld	ra,8(sp)
    80005296:	6402                	ld	s0,0(sp)
    80005298:	0141                	addi	sp,sp,16
    8000529a:	8082                	ret

000000008000529c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000529c:	1101                	addi	sp,sp,-32
    8000529e:	ec06                	sd	ra,24(sp)
    800052a0:	e822                	sd	s0,16(sp)
    800052a2:	e426                	sd	s1,8(sp)
    800052a4:	1000                	addi	s0,sp,32
    800052a6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800052a8:	ffffc097          	auipc	ra,0xffffc
    800052ac:	cf8080e7          	jalr	-776(ra) # 80000fa0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800052b0:	00d5151b          	slliw	a0,a0,0xd
    800052b4:	0c2017b7          	lui	a5,0xc201
    800052b8:	97aa                	add	a5,a5,a0
    800052ba:	c3c4                	sw	s1,4(a5)
}
    800052bc:	60e2                	ld	ra,24(sp)
    800052be:	6442                	ld	s0,16(sp)
    800052c0:	64a2                	ld	s1,8(sp)
    800052c2:	6105                	addi	sp,sp,32
    800052c4:	8082                	ret

00000000800052c6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800052c6:	1141                	addi	sp,sp,-16
    800052c8:	e406                	sd	ra,8(sp)
    800052ca:	e022                	sd	s0,0(sp)
    800052cc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800052ce:	479d                	li	a5,7
    800052d0:	06a7c963          	blt	a5,a0,80005342 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800052d4:	00236797          	auipc	a5,0x236
    800052d8:	d2c78793          	addi	a5,a5,-724 # 8023b000 <disk>
    800052dc:	00a78733          	add	a4,a5,a0
    800052e0:	6789                	lui	a5,0x2
    800052e2:	97ba                	add	a5,a5,a4
    800052e4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800052e8:	e7ad                	bnez	a5,80005352 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800052ea:	00451793          	slli	a5,a0,0x4
    800052ee:	00238717          	auipc	a4,0x238
    800052f2:	d1270713          	addi	a4,a4,-750 # 8023d000 <disk+0x2000>
    800052f6:	6314                	ld	a3,0(a4)
    800052f8:	96be                	add	a3,a3,a5
    800052fa:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800052fe:	6314                	ld	a3,0(a4)
    80005300:	96be                	add	a3,a3,a5
    80005302:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005306:	6314                	ld	a3,0(a4)
    80005308:	96be                	add	a3,a3,a5
    8000530a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000530e:	6318                	ld	a4,0(a4)
    80005310:	97ba                	add	a5,a5,a4
    80005312:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005316:	00236797          	auipc	a5,0x236
    8000531a:	cea78793          	addi	a5,a5,-790 # 8023b000 <disk>
    8000531e:	97aa                	add	a5,a5,a0
    80005320:	6509                	lui	a0,0x2
    80005322:	953e                	add	a0,a0,a5
    80005324:	4785                	li	a5,1
    80005326:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000532a:	00238517          	auipc	a0,0x238
    8000532e:	cee50513          	addi	a0,a0,-786 # 8023d018 <disk+0x2018>
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	4e2080e7          	jalr	1250(ra) # 80001814 <wakeup>
}
    8000533a:	60a2                	ld	ra,8(sp)
    8000533c:	6402                	ld	s0,0(sp)
    8000533e:	0141                	addi	sp,sp,16
    80005340:	8082                	ret
    panic("free_desc 1");
    80005342:	00003517          	auipc	a0,0x3
    80005346:	3fe50513          	addi	a0,a0,1022 # 80008740 <syscalls+0x320>
    8000534a:	00001097          	auipc	ra,0x1
    8000534e:	a1e080e7          	jalr	-1506(ra) # 80005d68 <panic>
    panic("free_desc 2");
    80005352:	00003517          	auipc	a0,0x3
    80005356:	3fe50513          	addi	a0,a0,1022 # 80008750 <syscalls+0x330>
    8000535a:	00001097          	auipc	ra,0x1
    8000535e:	a0e080e7          	jalr	-1522(ra) # 80005d68 <panic>

0000000080005362 <virtio_disk_init>:
{
    80005362:	1101                	addi	sp,sp,-32
    80005364:	ec06                	sd	ra,24(sp)
    80005366:	e822                	sd	s0,16(sp)
    80005368:	e426                	sd	s1,8(sp)
    8000536a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000536c:	00003597          	auipc	a1,0x3
    80005370:	3f458593          	addi	a1,a1,1012 # 80008760 <syscalls+0x340>
    80005374:	00238517          	auipc	a0,0x238
    80005378:	db450513          	addi	a0,a0,-588 # 8023d128 <disk+0x2128>
    8000537c:	00001097          	auipc	ra,0x1
    80005380:	ea6080e7          	jalr	-346(ra) # 80006222 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005384:	100017b7          	lui	a5,0x10001
    80005388:	4398                	lw	a4,0(a5)
    8000538a:	2701                	sext.w	a4,a4
    8000538c:	747277b7          	lui	a5,0x74727
    80005390:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005394:	0ef71163          	bne	a4,a5,80005476 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005398:	100017b7          	lui	a5,0x10001
    8000539c:	43dc                	lw	a5,4(a5)
    8000539e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053a0:	4705                	li	a4,1
    800053a2:	0ce79a63          	bne	a5,a4,80005476 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053a6:	100017b7          	lui	a5,0x10001
    800053aa:	479c                	lw	a5,8(a5)
    800053ac:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800053ae:	4709                	li	a4,2
    800053b0:	0ce79363          	bne	a5,a4,80005476 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800053b4:	100017b7          	lui	a5,0x10001
    800053b8:	47d8                	lw	a4,12(a5)
    800053ba:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053bc:	554d47b7          	lui	a5,0x554d4
    800053c0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800053c4:	0af71963          	bne	a4,a5,80005476 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053c8:	100017b7          	lui	a5,0x10001
    800053cc:	4705                	li	a4,1
    800053ce:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053d0:	470d                	li	a4,3
    800053d2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800053d4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800053d6:	c7ffe737          	lui	a4,0xc7ffe
    800053da:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47db851f>
    800053de:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800053e0:	2701                	sext.w	a4,a4
    800053e2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053e4:	472d                	li	a4,11
    800053e6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800053e8:	473d                	li	a4,15
    800053ea:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800053ec:	6705                	lui	a4,0x1
    800053ee:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800053f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800053f4:	5bdc                	lw	a5,52(a5)
    800053f6:	2781                	sext.w	a5,a5
  if(max == 0)
    800053f8:	c7d9                	beqz	a5,80005486 <virtio_disk_init+0x124>
  if(max < NUM)
    800053fa:	471d                	li	a4,7
    800053fc:	08f77d63          	bgeu	a4,a5,80005496 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005400:	100014b7          	lui	s1,0x10001
    80005404:	47a1                	li	a5,8
    80005406:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005408:	6609                	lui	a2,0x2
    8000540a:	4581                	li	a1,0
    8000540c:	00236517          	auipc	a0,0x236
    80005410:	bf450513          	addi	a0,a0,-1036 # 8023b000 <disk>
    80005414:	ffffb097          	auipc	ra,0xffffb
    80005418:	ea0080e7          	jalr	-352(ra) # 800002b4 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000541c:	00236717          	auipc	a4,0x236
    80005420:	be470713          	addi	a4,a4,-1052 # 8023b000 <disk>
    80005424:	00c75793          	srli	a5,a4,0xc
    80005428:	2781                	sext.w	a5,a5
    8000542a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000542c:	00238797          	auipc	a5,0x238
    80005430:	bd478793          	addi	a5,a5,-1068 # 8023d000 <disk+0x2000>
    80005434:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005436:	00236717          	auipc	a4,0x236
    8000543a:	c4a70713          	addi	a4,a4,-950 # 8023b080 <disk+0x80>
    8000543e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005440:	00237717          	auipc	a4,0x237
    80005444:	bc070713          	addi	a4,a4,-1088 # 8023c000 <disk+0x1000>
    80005448:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000544a:	4705                	li	a4,1
    8000544c:	00e78c23          	sb	a4,24(a5)
    80005450:	00e78ca3          	sb	a4,25(a5)
    80005454:	00e78d23          	sb	a4,26(a5)
    80005458:	00e78da3          	sb	a4,27(a5)
    8000545c:	00e78e23          	sb	a4,28(a5)
    80005460:	00e78ea3          	sb	a4,29(a5)
    80005464:	00e78f23          	sb	a4,30(a5)
    80005468:	00e78fa3          	sb	a4,31(a5)
}
    8000546c:	60e2                	ld	ra,24(sp)
    8000546e:	6442                	ld	s0,16(sp)
    80005470:	64a2                	ld	s1,8(sp)
    80005472:	6105                	addi	sp,sp,32
    80005474:	8082                	ret
    panic("could not find virtio disk");
    80005476:	00003517          	auipc	a0,0x3
    8000547a:	2fa50513          	addi	a0,a0,762 # 80008770 <syscalls+0x350>
    8000547e:	00001097          	auipc	ra,0x1
    80005482:	8ea080e7          	jalr	-1814(ra) # 80005d68 <panic>
    panic("virtio disk has no queue 0");
    80005486:	00003517          	auipc	a0,0x3
    8000548a:	30a50513          	addi	a0,a0,778 # 80008790 <syscalls+0x370>
    8000548e:	00001097          	auipc	ra,0x1
    80005492:	8da080e7          	jalr	-1830(ra) # 80005d68 <panic>
    panic("virtio disk max queue too short");
    80005496:	00003517          	auipc	a0,0x3
    8000549a:	31a50513          	addi	a0,a0,794 # 800087b0 <syscalls+0x390>
    8000549e:	00001097          	auipc	ra,0x1
    800054a2:	8ca080e7          	jalr	-1846(ra) # 80005d68 <panic>

00000000800054a6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800054a6:	7159                	addi	sp,sp,-112
    800054a8:	f486                	sd	ra,104(sp)
    800054aa:	f0a2                	sd	s0,96(sp)
    800054ac:	eca6                	sd	s1,88(sp)
    800054ae:	e8ca                	sd	s2,80(sp)
    800054b0:	e4ce                	sd	s3,72(sp)
    800054b2:	e0d2                	sd	s4,64(sp)
    800054b4:	fc56                	sd	s5,56(sp)
    800054b6:	f85a                	sd	s6,48(sp)
    800054b8:	f45e                	sd	s7,40(sp)
    800054ba:	f062                	sd	s8,32(sp)
    800054bc:	ec66                	sd	s9,24(sp)
    800054be:	e86a                	sd	s10,16(sp)
    800054c0:	1880                	addi	s0,sp,112
    800054c2:	892a                	mv	s2,a0
    800054c4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800054c6:	00c52c83          	lw	s9,12(a0)
    800054ca:	001c9c9b          	slliw	s9,s9,0x1
    800054ce:	1c82                	slli	s9,s9,0x20
    800054d0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800054d4:	00238517          	auipc	a0,0x238
    800054d8:	c5450513          	addi	a0,a0,-940 # 8023d128 <disk+0x2128>
    800054dc:	00001097          	auipc	ra,0x1
    800054e0:	dd6080e7          	jalr	-554(ra) # 800062b2 <acquire>
  for(int i = 0; i < 3; i++){
    800054e4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800054e6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800054e8:	00236b97          	auipc	s7,0x236
    800054ec:	b18b8b93          	addi	s7,s7,-1256 # 8023b000 <disk>
    800054f0:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    800054f2:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    800054f4:	8a4e                	mv	s4,s3
    800054f6:	a051                	j	8000557a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    800054f8:	00fb86b3          	add	a3,s7,a5
    800054fc:	96da                	add	a3,a3,s6
    800054fe:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005502:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005504:	0207c563          	bltz	a5,8000552e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005508:	2485                	addiw	s1,s1,1
    8000550a:	0711                	addi	a4,a4,4
    8000550c:	25548063          	beq	s1,s5,8000574c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80005510:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005512:	00238697          	auipc	a3,0x238
    80005516:	b0668693          	addi	a3,a3,-1274 # 8023d018 <disk+0x2018>
    8000551a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000551c:	0006c583          	lbu	a1,0(a3)
    80005520:	fde1                	bnez	a1,800054f8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005522:	2785                	addiw	a5,a5,1
    80005524:	0685                	addi	a3,a3,1
    80005526:	ff879be3          	bne	a5,s8,8000551c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000552a:	57fd                	li	a5,-1
    8000552c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000552e:	02905a63          	blez	s1,80005562 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005532:	f9042503          	lw	a0,-112(s0)
    80005536:	00000097          	auipc	ra,0x0
    8000553a:	d90080e7          	jalr	-624(ra) # 800052c6 <free_desc>
      for(int j = 0; j < i; j++)
    8000553e:	4785                	li	a5,1
    80005540:	0297d163          	bge	a5,s1,80005562 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005544:	f9442503          	lw	a0,-108(s0)
    80005548:	00000097          	auipc	ra,0x0
    8000554c:	d7e080e7          	jalr	-642(ra) # 800052c6 <free_desc>
      for(int j = 0; j < i; j++)
    80005550:	4789                	li	a5,2
    80005552:	0097d863          	bge	a5,s1,80005562 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80005556:	f9842503          	lw	a0,-104(s0)
    8000555a:	00000097          	auipc	ra,0x0
    8000555e:	d6c080e7          	jalr	-660(ra) # 800052c6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005562:	00238597          	auipc	a1,0x238
    80005566:	bc658593          	addi	a1,a1,-1082 # 8023d128 <disk+0x2128>
    8000556a:	00238517          	auipc	a0,0x238
    8000556e:	aae50513          	addi	a0,a0,-1362 # 8023d018 <disk+0x2018>
    80005572:	ffffc097          	auipc	ra,0xffffc
    80005576:	116080e7          	jalr	278(ra) # 80001688 <sleep>
  for(int i = 0; i < 3; i++){
    8000557a:	f9040713          	addi	a4,s0,-112
    8000557e:	84ce                	mv	s1,s3
    80005580:	bf41                	j	80005510 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005582:	20058713          	addi	a4,a1,512
    80005586:	00471693          	slli	a3,a4,0x4
    8000558a:	00236717          	auipc	a4,0x236
    8000558e:	a7670713          	addi	a4,a4,-1418 # 8023b000 <disk>
    80005592:	9736                	add	a4,a4,a3
    80005594:	4685                	li	a3,1
    80005596:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000559a:	20058713          	addi	a4,a1,512
    8000559e:	00471693          	slli	a3,a4,0x4
    800055a2:	00236717          	auipc	a4,0x236
    800055a6:	a5e70713          	addi	a4,a4,-1442 # 8023b000 <disk>
    800055aa:	9736                	add	a4,a4,a3
    800055ac:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800055b0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800055b4:	7679                	lui	a2,0xffffe
    800055b6:	963e                	add	a2,a2,a5
    800055b8:	00238697          	auipc	a3,0x238
    800055bc:	a4868693          	addi	a3,a3,-1464 # 8023d000 <disk+0x2000>
    800055c0:	6298                	ld	a4,0(a3)
    800055c2:	9732                	add	a4,a4,a2
    800055c4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800055c6:	6298                	ld	a4,0(a3)
    800055c8:	9732                	add	a4,a4,a2
    800055ca:	4541                	li	a0,16
    800055cc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800055ce:	6298                	ld	a4,0(a3)
    800055d0:	9732                	add	a4,a4,a2
    800055d2:	4505                	li	a0,1
    800055d4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800055d8:	f9442703          	lw	a4,-108(s0)
    800055dc:	6288                	ld	a0,0(a3)
    800055de:	962a                	add	a2,a2,a0
    800055e0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7fdb7dce>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800055e4:	0712                	slli	a4,a4,0x4
    800055e6:	6290                	ld	a2,0(a3)
    800055e8:	963a                	add	a2,a2,a4
    800055ea:	05890513          	addi	a0,s2,88
    800055ee:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800055f0:	6294                	ld	a3,0(a3)
    800055f2:	96ba                	add	a3,a3,a4
    800055f4:	40000613          	li	a2,1024
    800055f8:	c690                	sw	a2,8(a3)
  if(write)
    800055fa:	140d0063          	beqz	s10,8000573a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800055fe:	00238697          	auipc	a3,0x238
    80005602:	a026b683          	ld	a3,-1534(a3) # 8023d000 <disk+0x2000>
    80005606:	96ba                	add	a3,a3,a4
    80005608:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000560c:	00236817          	auipc	a6,0x236
    80005610:	9f480813          	addi	a6,a6,-1548 # 8023b000 <disk>
    80005614:	00238517          	auipc	a0,0x238
    80005618:	9ec50513          	addi	a0,a0,-1556 # 8023d000 <disk+0x2000>
    8000561c:	6114                	ld	a3,0(a0)
    8000561e:	96ba                	add	a3,a3,a4
    80005620:	00c6d603          	lhu	a2,12(a3)
    80005624:	00166613          	ori	a2,a2,1
    80005628:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000562c:	f9842683          	lw	a3,-104(s0)
    80005630:	6110                	ld	a2,0(a0)
    80005632:	9732                	add	a4,a4,a2
    80005634:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005638:	20058613          	addi	a2,a1,512
    8000563c:	0612                	slli	a2,a2,0x4
    8000563e:	9642                	add	a2,a2,a6
    80005640:	577d                	li	a4,-1
    80005642:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005646:	00469713          	slli	a4,a3,0x4
    8000564a:	6114                	ld	a3,0(a0)
    8000564c:	96ba                	add	a3,a3,a4
    8000564e:	03078793          	addi	a5,a5,48
    80005652:	97c2                	add	a5,a5,a6
    80005654:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80005656:	611c                	ld	a5,0(a0)
    80005658:	97ba                	add	a5,a5,a4
    8000565a:	4685                	li	a3,1
    8000565c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000565e:	611c                	ld	a5,0(a0)
    80005660:	97ba                	add	a5,a5,a4
    80005662:	4809                	li	a6,2
    80005664:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80005668:	611c                	ld	a5,0(a0)
    8000566a:	973e                	add	a4,a4,a5
    8000566c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005670:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80005674:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005678:	6518                	ld	a4,8(a0)
    8000567a:	00275783          	lhu	a5,2(a4)
    8000567e:	8b9d                	andi	a5,a5,7
    80005680:	0786                	slli	a5,a5,0x1
    80005682:	97ba                	add	a5,a5,a4
    80005684:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80005688:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000568c:	6518                	ld	a4,8(a0)
    8000568e:	00275783          	lhu	a5,2(a4)
    80005692:	2785                	addiw	a5,a5,1
    80005694:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005698:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000569c:	100017b7          	lui	a5,0x10001
    800056a0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800056a4:	00492703          	lw	a4,4(s2)
    800056a8:	4785                	li	a5,1
    800056aa:	02f71163          	bne	a4,a5,800056cc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800056ae:	00238997          	auipc	s3,0x238
    800056b2:	a7a98993          	addi	s3,s3,-1414 # 8023d128 <disk+0x2128>
  while(b->disk == 1) {
    800056b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800056b8:	85ce                	mv	a1,s3
    800056ba:	854a                	mv	a0,s2
    800056bc:	ffffc097          	auipc	ra,0xffffc
    800056c0:	fcc080e7          	jalr	-52(ra) # 80001688 <sleep>
  while(b->disk == 1) {
    800056c4:	00492783          	lw	a5,4(s2)
    800056c8:	fe9788e3          	beq	a5,s1,800056b8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800056cc:	f9042903          	lw	s2,-112(s0)
    800056d0:	20090793          	addi	a5,s2,512
    800056d4:	00479713          	slli	a4,a5,0x4
    800056d8:	00236797          	auipc	a5,0x236
    800056dc:	92878793          	addi	a5,a5,-1752 # 8023b000 <disk>
    800056e0:	97ba                	add	a5,a5,a4
    800056e2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800056e6:	00238997          	auipc	s3,0x238
    800056ea:	91a98993          	addi	s3,s3,-1766 # 8023d000 <disk+0x2000>
    800056ee:	00491713          	slli	a4,s2,0x4
    800056f2:	0009b783          	ld	a5,0(s3)
    800056f6:	97ba                	add	a5,a5,a4
    800056f8:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800056fc:	854a                	mv	a0,s2
    800056fe:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005702:	00000097          	auipc	ra,0x0
    80005706:	bc4080e7          	jalr	-1084(ra) # 800052c6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000570a:	8885                	andi	s1,s1,1
    8000570c:	f0ed                	bnez	s1,800056ee <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000570e:	00238517          	auipc	a0,0x238
    80005712:	a1a50513          	addi	a0,a0,-1510 # 8023d128 <disk+0x2128>
    80005716:	00001097          	auipc	ra,0x1
    8000571a:	c50080e7          	jalr	-944(ra) # 80006366 <release>
}
    8000571e:	70a6                	ld	ra,104(sp)
    80005720:	7406                	ld	s0,96(sp)
    80005722:	64e6                	ld	s1,88(sp)
    80005724:	6946                	ld	s2,80(sp)
    80005726:	69a6                	ld	s3,72(sp)
    80005728:	6a06                	ld	s4,64(sp)
    8000572a:	7ae2                	ld	s5,56(sp)
    8000572c:	7b42                	ld	s6,48(sp)
    8000572e:	7ba2                	ld	s7,40(sp)
    80005730:	7c02                	ld	s8,32(sp)
    80005732:	6ce2                	ld	s9,24(sp)
    80005734:	6d42                	ld	s10,16(sp)
    80005736:	6165                	addi	sp,sp,112
    80005738:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000573a:	00238697          	auipc	a3,0x238
    8000573e:	8c66b683          	ld	a3,-1850(a3) # 8023d000 <disk+0x2000>
    80005742:	96ba                	add	a3,a3,a4
    80005744:	4609                	li	a2,2
    80005746:	00c69623          	sh	a2,12(a3)
    8000574a:	b5c9                	j	8000560c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000574c:	f9042583          	lw	a1,-112(s0)
    80005750:	20058793          	addi	a5,a1,512
    80005754:	0792                	slli	a5,a5,0x4
    80005756:	00236517          	auipc	a0,0x236
    8000575a:	95250513          	addi	a0,a0,-1710 # 8023b0a8 <disk+0xa8>
    8000575e:	953e                	add	a0,a0,a5
  if(write)
    80005760:	e20d11e3          	bnez	s10,80005582 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005764:	20058713          	addi	a4,a1,512
    80005768:	00471693          	slli	a3,a4,0x4
    8000576c:	00236717          	auipc	a4,0x236
    80005770:	89470713          	addi	a4,a4,-1900 # 8023b000 <disk>
    80005774:	9736                	add	a4,a4,a3
    80005776:	0a072423          	sw	zero,168(a4)
    8000577a:	b505                	j	8000559a <virtio_disk_rw+0xf4>

000000008000577c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000577c:	1101                	addi	sp,sp,-32
    8000577e:	ec06                	sd	ra,24(sp)
    80005780:	e822                	sd	s0,16(sp)
    80005782:	e426                	sd	s1,8(sp)
    80005784:	e04a                	sd	s2,0(sp)
    80005786:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005788:	00238517          	auipc	a0,0x238
    8000578c:	9a050513          	addi	a0,a0,-1632 # 8023d128 <disk+0x2128>
    80005790:	00001097          	auipc	ra,0x1
    80005794:	b22080e7          	jalr	-1246(ra) # 800062b2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005798:	10001737          	lui	a4,0x10001
    8000579c:	533c                	lw	a5,96(a4)
    8000579e:	8b8d                	andi	a5,a5,3
    800057a0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800057a2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800057a6:	00238797          	auipc	a5,0x238
    800057aa:	85a78793          	addi	a5,a5,-1958 # 8023d000 <disk+0x2000>
    800057ae:	6b94                	ld	a3,16(a5)
    800057b0:	0207d703          	lhu	a4,32(a5)
    800057b4:	0026d783          	lhu	a5,2(a3)
    800057b8:	06f70163          	beq	a4,a5,8000581a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057bc:	00236917          	auipc	s2,0x236
    800057c0:	84490913          	addi	s2,s2,-1980 # 8023b000 <disk>
    800057c4:	00238497          	auipc	s1,0x238
    800057c8:	83c48493          	addi	s1,s1,-1988 # 8023d000 <disk+0x2000>
    __sync_synchronize();
    800057cc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057d0:	6898                	ld	a4,16(s1)
    800057d2:	0204d783          	lhu	a5,32(s1)
    800057d6:	8b9d                	andi	a5,a5,7
    800057d8:	078e                	slli	a5,a5,0x3
    800057da:	97ba                	add	a5,a5,a4
    800057dc:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800057de:	20078713          	addi	a4,a5,512
    800057e2:	0712                	slli	a4,a4,0x4
    800057e4:	974a                	add	a4,a4,s2
    800057e6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800057ea:	e731                	bnez	a4,80005836 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800057ec:	20078793          	addi	a5,a5,512
    800057f0:	0792                	slli	a5,a5,0x4
    800057f2:	97ca                	add	a5,a5,s2
    800057f4:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800057f6:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800057fa:	ffffc097          	auipc	ra,0xffffc
    800057fe:	01a080e7          	jalr	26(ra) # 80001814 <wakeup>

    disk.used_idx += 1;
    80005802:	0204d783          	lhu	a5,32(s1)
    80005806:	2785                	addiw	a5,a5,1
    80005808:	17c2                	slli	a5,a5,0x30
    8000580a:	93c1                	srli	a5,a5,0x30
    8000580c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005810:	6898                	ld	a4,16(s1)
    80005812:	00275703          	lhu	a4,2(a4)
    80005816:	faf71be3          	bne	a4,a5,800057cc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000581a:	00238517          	auipc	a0,0x238
    8000581e:	90e50513          	addi	a0,a0,-1778 # 8023d128 <disk+0x2128>
    80005822:	00001097          	auipc	ra,0x1
    80005826:	b44080e7          	jalr	-1212(ra) # 80006366 <release>
}
    8000582a:	60e2                	ld	ra,24(sp)
    8000582c:	6442                	ld	s0,16(sp)
    8000582e:	64a2                	ld	s1,8(sp)
    80005830:	6902                	ld	s2,0(sp)
    80005832:	6105                	addi	sp,sp,32
    80005834:	8082                	ret
      panic("virtio_disk_intr status");
    80005836:	00003517          	auipc	a0,0x3
    8000583a:	f9a50513          	addi	a0,a0,-102 # 800087d0 <syscalls+0x3b0>
    8000583e:	00000097          	auipc	ra,0x0
    80005842:	52a080e7          	jalr	1322(ra) # 80005d68 <panic>

0000000080005846 <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80005846:	1141                	addi	sp,sp,-16
    80005848:	e422                	sd	s0,8(sp)
    8000584a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000584c:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005850:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80005854:	0037979b          	slliw	a5,a5,0x3
    80005858:	02004737          	lui	a4,0x2004
    8000585c:	97ba                	add	a5,a5,a4
    8000585e:	0200c737          	lui	a4,0x200c
    80005862:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005866:	000f4637          	lui	a2,0xf4
    8000586a:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    8000586e:	95b2                	add	a1,a1,a2
    80005870:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005872:	00269713          	slli	a4,a3,0x2
    80005876:	9736                	add	a4,a4,a3
    80005878:	00371693          	slli	a3,a4,0x3
    8000587c:	00238717          	auipc	a4,0x238
    80005880:	78470713          	addi	a4,a4,1924 # 8023e000 <timer_scratch>
    80005884:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005886:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005888:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000588a:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000588e:	00000797          	auipc	a5,0x0
    80005892:	97278793          	addi	a5,a5,-1678 # 80005200 <timervec>
    80005896:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000589a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000589e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800058a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    800058a6:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    800058aa:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    800058ae:	30479073          	csrw	mie,a5
}
    800058b2:	6422                	ld	s0,8(sp)
    800058b4:	0141                	addi	sp,sp,16
    800058b6:	8082                	ret

00000000800058b8 <start>:
{
    800058b8:	1141                	addi	sp,sp,-16
    800058ba:	e406                	sd	ra,8(sp)
    800058bc:	e022                	sd	s0,0(sp)
    800058be:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800058c0:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800058c4:	7779                	lui	a4,0xffffe
    800058c6:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdb85bf>
    800058ca:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800058cc:	6705                	lui	a4,0x1
    800058ce:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800058d2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800058d4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800058d8:	ffffb797          	auipc	a5,0xffffb
    800058dc:	b8a78793          	addi	a5,a5,-1142 # 80000462 <main>
    800058e0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800058e4:	4781                	li	a5,0
    800058e6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800058ea:	67c1                	lui	a5,0x10
    800058ec:	17fd                	addi	a5,a5,-1
    800058ee:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800058f2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800058f6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800058fa:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800058fe:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005902:	57fd                	li	a5,-1
    80005904:	83a9                	srli	a5,a5,0xa
    80005906:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000590a:	47bd                	li	a5,15
    8000590c:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005910:	00000097          	auipc	ra,0x0
    80005914:	f36080e7          	jalr	-202(ra) # 80005846 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005918:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    8000591c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    8000591e:	823e                	mv	tp,a5
  asm volatile("mret");
    80005920:	30200073          	mret
}
    80005924:	60a2                	ld	ra,8(sp)
    80005926:	6402                	ld	s0,0(sp)
    80005928:	0141                	addi	sp,sp,16
    8000592a:	8082                	ret

000000008000592c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000592c:	715d                	addi	sp,sp,-80
    8000592e:	e486                	sd	ra,72(sp)
    80005930:	e0a2                	sd	s0,64(sp)
    80005932:	fc26                	sd	s1,56(sp)
    80005934:	f84a                	sd	s2,48(sp)
    80005936:	f44e                	sd	s3,40(sp)
    80005938:	f052                	sd	s4,32(sp)
    8000593a:	ec56                	sd	s5,24(sp)
    8000593c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000593e:	04c05663          	blez	a2,8000598a <consolewrite+0x5e>
    80005942:	8a2a                	mv	s4,a0
    80005944:	84ae                	mv	s1,a1
    80005946:	89b2                	mv	s3,a2
    80005948:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000594a:	5afd                	li	s5,-1
    8000594c:	4685                	li	a3,1
    8000594e:	8626                	mv	a2,s1
    80005950:	85d2                	mv	a1,s4
    80005952:	fbf40513          	addi	a0,s0,-65
    80005956:	ffffc097          	auipc	ra,0xffffc
    8000595a:	12c080e7          	jalr	300(ra) # 80001a82 <either_copyin>
    8000595e:	01550c63          	beq	a0,s5,80005976 <consolewrite+0x4a>
      break;
    uartputc(c);
    80005962:	fbf44503          	lbu	a0,-65(s0)
    80005966:	00000097          	auipc	ra,0x0
    8000596a:	78e080e7          	jalr	1934(ra) # 800060f4 <uartputc>
  for(i = 0; i < n; i++){
    8000596e:	2905                	addiw	s2,s2,1
    80005970:	0485                	addi	s1,s1,1
    80005972:	fd299de3          	bne	s3,s2,8000594c <consolewrite+0x20>
  }

  return i;
}
    80005976:	854a                	mv	a0,s2
    80005978:	60a6                	ld	ra,72(sp)
    8000597a:	6406                	ld	s0,64(sp)
    8000597c:	74e2                	ld	s1,56(sp)
    8000597e:	7942                	ld	s2,48(sp)
    80005980:	79a2                	ld	s3,40(sp)
    80005982:	7a02                	ld	s4,32(sp)
    80005984:	6ae2                	ld	s5,24(sp)
    80005986:	6161                	addi	sp,sp,80
    80005988:	8082                	ret
  for(i = 0; i < n; i++){
    8000598a:	4901                	li	s2,0
    8000598c:	b7ed                	j	80005976 <consolewrite+0x4a>

000000008000598e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000598e:	7119                	addi	sp,sp,-128
    80005990:	fc86                	sd	ra,120(sp)
    80005992:	f8a2                	sd	s0,112(sp)
    80005994:	f4a6                	sd	s1,104(sp)
    80005996:	f0ca                	sd	s2,96(sp)
    80005998:	ecce                	sd	s3,88(sp)
    8000599a:	e8d2                	sd	s4,80(sp)
    8000599c:	e4d6                	sd	s5,72(sp)
    8000599e:	e0da                	sd	s6,64(sp)
    800059a0:	fc5e                	sd	s7,56(sp)
    800059a2:	f862                	sd	s8,48(sp)
    800059a4:	f466                	sd	s9,40(sp)
    800059a6:	f06a                	sd	s10,32(sp)
    800059a8:	ec6e                	sd	s11,24(sp)
    800059aa:	0100                	addi	s0,sp,128
    800059ac:	8b2a                	mv	s6,a0
    800059ae:	8aae                	mv	s5,a1
    800059b0:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    800059b2:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    800059b6:	00240517          	auipc	a0,0x240
    800059ba:	78a50513          	addi	a0,a0,1930 # 80246140 <cons>
    800059be:	00001097          	auipc	ra,0x1
    800059c2:	8f4080e7          	jalr	-1804(ra) # 800062b2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800059c6:	00240497          	auipc	s1,0x240
    800059ca:	77a48493          	addi	s1,s1,1914 # 80246140 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800059ce:	89a6                	mv	s3,s1
    800059d0:	00241917          	auipc	s2,0x241
    800059d4:	80890913          	addi	s2,s2,-2040 # 802461d8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800059d8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800059da:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800059dc:	4da9                	li	s11,10
  while(n > 0){
    800059de:	07405863          	blez	s4,80005a4e <consoleread+0xc0>
    while(cons.r == cons.w){
    800059e2:	0984a783          	lw	a5,152(s1)
    800059e6:	09c4a703          	lw	a4,156(s1)
    800059ea:	02f71463          	bne	a4,a5,80005a12 <consoleread+0x84>
      if(myproc()->killed){
    800059ee:	ffffb097          	auipc	ra,0xffffb
    800059f2:	5de080e7          	jalr	1502(ra) # 80000fcc <myproc>
    800059f6:	551c                	lw	a5,40(a0)
    800059f8:	e7b5                	bnez	a5,80005a64 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800059fa:	85ce                	mv	a1,s3
    800059fc:	854a                	mv	a0,s2
    800059fe:	ffffc097          	auipc	ra,0xffffc
    80005a02:	c8a080e7          	jalr	-886(ra) # 80001688 <sleep>
    while(cons.r == cons.w){
    80005a06:	0984a783          	lw	a5,152(s1)
    80005a0a:	09c4a703          	lw	a4,156(s1)
    80005a0e:	fef700e3          	beq	a4,a5,800059ee <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80005a12:	0017871b          	addiw	a4,a5,1
    80005a16:	08e4ac23          	sw	a4,152(s1)
    80005a1a:	07f7f713          	andi	a4,a5,127
    80005a1e:	9726                	add	a4,a4,s1
    80005a20:	01874703          	lbu	a4,24(a4)
    80005a24:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80005a28:	079c0663          	beq	s8,s9,80005a94 <consoleread+0x106>
    cbuf = c;
    80005a2c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005a30:	4685                	li	a3,1
    80005a32:	f8f40613          	addi	a2,s0,-113
    80005a36:	85d6                	mv	a1,s5
    80005a38:	855a                	mv	a0,s6
    80005a3a:	ffffc097          	auipc	ra,0xffffc
    80005a3e:	ff2080e7          	jalr	-14(ra) # 80001a2c <either_copyout>
    80005a42:	01a50663          	beq	a0,s10,80005a4e <consoleread+0xc0>
    dst++;
    80005a46:	0a85                	addi	s5,s5,1
    --n;
    80005a48:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80005a4a:	f9bc1ae3          	bne	s8,s11,800059de <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005a4e:	00240517          	auipc	a0,0x240
    80005a52:	6f250513          	addi	a0,a0,1778 # 80246140 <cons>
    80005a56:	00001097          	auipc	ra,0x1
    80005a5a:	910080e7          	jalr	-1776(ra) # 80006366 <release>

  return target - n;
    80005a5e:	414b853b          	subw	a0,s7,s4
    80005a62:	a811                	j	80005a76 <consoleread+0xe8>
        release(&cons.lock);
    80005a64:	00240517          	auipc	a0,0x240
    80005a68:	6dc50513          	addi	a0,a0,1756 # 80246140 <cons>
    80005a6c:	00001097          	auipc	ra,0x1
    80005a70:	8fa080e7          	jalr	-1798(ra) # 80006366 <release>
        return -1;
    80005a74:	557d                	li	a0,-1
}
    80005a76:	70e6                	ld	ra,120(sp)
    80005a78:	7446                	ld	s0,112(sp)
    80005a7a:	74a6                	ld	s1,104(sp)
    80005a7c:	7906                	ld	s2,96(sp)
    80005a7e:	69e6                	ld	s3,88(sp)
    80005a80:	6a46                	ld	s4,80(sp)
    80005a82:	6aa6                	ld	s5,72(sp)
    80005a84:	6b06                	ld	s6,64(sp)
    80005a86:	7be2                	ld	s7,56(sp)
    80005a88:	7c42                	ld	s8,48(sp)
    80005a8a:	7ca2                	ld	s9,40(sp)
    80005a8c:	7d02                	ld	s10,32(sp)
    80005a8e:	6de2                	ld	s11,24(sp)
    80005a90:	6109                	addi	sp,sp,128
    80005a92:	8082                	ret
      if(n < target){
    80005a94:	000a071b          	sext.w	a4,s4
    80005a98:	fb777be3          	bgeu	a4,s7,80005a4e <consoleread+0xc0>
        cons.r--;
    80005a9c:	00240717          	auipc	a4,0x240
    80005aa0:	72f72e23          	sw	a5,1852(a4) # 802461d8 <cons+0x98>
    80005aa4:	b76d                	j	80005a4e <consoleread+0xc0>

0000000080005aa6 <consputc>:
{
    80005aa6:	1141                	addi	sp,sp,-16
    80005aa8:	e406                	sd	ra,8(sp)
    80005aaa:	e022                	sd	s0,0(sp)
    80005aac:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005aae:	10000793          	li	a5,256
    80005ab2:	00f50a63          	beq	a0,a5,80005ac6 <consputc+0x20>
    uartputc_sync(c);
    80005ab6:	00000097          	auipc	ra,0x0
    80005aba:	564080e7          	jalr	1380(ra) # 8000601a <uartputc_sync>
}
    80005abe:	60a2                	ld	ra,8(sp)
    80005ac0:	6402                	ld	s0,0(sp)
    80005ac2:	0141                	addi	sp,sp,16
    80005ac4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005ac6:	4521                	li	a0,8
    80005ac8:	00000097          	auipc	ra,0x0
    80005acc:	552080e7          	jalr	1362(ra) # 8000601a <uartputc_sync>
    80005ad0:	02000513          	li	a0,32
    80005ad4:	00000097          	auipc	ra,0x0
    80005ad8:	546080e7          	jalr	1350(ra) # 8000601a <uartputc_sync>
    80005adc:	4521                	li	a0,8
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	53c080e7          	jalr	1340(ra) # 8000601a <uartputc_sync>
    80005ae6:	bfe1                	j	80005abe <consputc+0x18>

0000000080005ae8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005ae8:	1101                	addi	sp,sp,-32
    80005aea:	ec06                	sd	ra,24(sp)
    80005aec:	e822                	sd	s0,16(sp)
    80005aee:	e426                	sd	s1,8(sp)
    80005af0:	e04a                	sd	s2,0(sp)
    80005af2:	1000                	addi	s0,sp,32
    80005af4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005af6:	00240517          	auipc	a0,0x240
    80005afa:	64a50513          	addi	a0,a0,1610 # 80246140 <cons>
    80005afe:	00000097          	auipc	ra,0x0
    80005b02:	7b4080e7          	jalr	1972(ra) # 800062b2 <acquire>

  switch(c){
    80005b06:	47d5                	li	a5,21
    80005b08:	0af48663          	beq	s1,a5,80005bb4 <consoleintr+0xcc>
    80005b0c:	0297ca63          	blt	a5,s1,80005b40 <consoleintr+0x58>
    80005b10:	47a1                	li	a5,8
    80005b12:	0ef48763          	beq	s1,a5,80005c00 <consoleintr+0x118>
    80005b16:	47c1                	li	a5,16
    80005b18:	10f49a63          	bne	s1,a5,80005c2c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005b1c:	ffffc097          	auipc	ra,0xffffc
    80005b20:	fbc080e7          	jalr	-68(ra) # 80001ad8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005b24:	00240517          	auipc	a0,0x240
    80005b28:	61c50513          	addi	a0,a0,1564 # 80246140 <cons>
    80005b2c:	00001097          	auipc	ra,0x1
    80005b30:	83a080e7          	jalr	-1990(ra) # 80006366 <release>
}
    80005b34:	60e2                	ld	ra,24(sp)
    80005b36:	6442                	ld	s0,16(sp)
    80005b38:	64a2                	ld	s1,8(sp)
    80005b3a:	6902                	ld	s2,0(sp)
    80005b3c:	6105                	addi	sp,sp,32
    80005b3e:	8082                	ret
  switch(c){
    80005b40:	07f00793          	li	a5,127
    80005b44:	0af48e63          	beq	s1,a5,80005c00 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005b48:	00240717          	auipc	a4,0x240
    80005b4c:	5f870713          	addi	a4,a4,1528 # 80246140 <cons>
    80005b50:	0a072783          	lw	a5,160(a4)
    80005b54:	09872703          	lw	a4,152(a4)
    80005b58:	9f99                	subw	a5,a5,a4
    80005b5a:	07f00713          	li	a4,127
    80005b5e:	fcf763e3          	bltu	a4,a5,80005b24 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005b62:	47b5                	li	a5,13
    80005b64:	0cf48763          	beq	s1,a5,80005c32 <consoleintr+0x14a>
      consputc(c);
    80005b68:	8526                	mv	a0,s1
    80005b6a:	00000097          	auipc	ra,0x0
    80005b6e:	f3c080e7          	jalr	-196(ra) # 80005aa6 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005b72:	00240797          	auipc	a5,0x240
    80005b76:	5ce78793          	addi	a5,a5,1486 # 80246140 <cons>
    80005b7a:	0a07a703          	lw	a4,160(a5)
    80005b7e:	0017069b          	addiw	a3,a4,1
    80005b82:	0006861b          	sext.w	a2,a3
    80005b86:	0ad7a023          	sw	a3,160(a5)
    80005b8a:	07f77713          	andi	a4,a4,127
    80005b8e:	97ba                	add	a5,a5,a4
    80005b90:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80005b94:	47a9                	li	a5,10
    80005b96:	0cf48563          	beq	s1,a5,80005c60 <consoleintr+0x178>
    80005b9a:	4791                	li	a5,4
    80005b9c:	0cf48263          	beq	s1,a5,80005c60 <consoleintr+0x178>
    80005ba0:	00240797          	auipc	a5,0x240
    80005ba4:	6387a783          	lw	a5,1592(a5) # 802461d8 <cons+0x98>
    80005ba8:	0807879b          	addiw	a5,a5,128
    80005bac:	f6f61ce3          	bne	a2,a5,80005b24 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005bb0:	863e                	mv	a2,a5
    80005bb2:	a07d                	j	80005c60 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005bb4:	00240717          	auipc	a4,0x240
    80005bb8:	58c70713          	addi	a4,a4,1420 # 80246140 <cons>
    80005bbc:	0a072783          	lw	a5,160(a4)
    80005bc0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005bc4:	00240497          	auipc	s1,0x240
    80005bc8:	57c48493          	addi	s1,s1,1404 # 80246140 <cons>
    while(cons.e != cons.w &&
    80005bcc:	4929                	li	s2,10
    80005bce:	f4f70be3          	beq	a4,a5,80005b24 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80005bd2:	37fd                	addiw	a5,a5,-1
    80005bd4:	07f7f713          	andi	a4,a5,127
    80005bd8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005bda:	01874703          	lbu	a4,24(a4)
    80005bde:	f52703e3          	beq	a4,s2,80005b24 <consoleintr+0x3c>
      cons.e--;
    80005be2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005be6:	10000513          	li	a0,256
    80005bea:	00000097          	auipc	ra,0x0
    80005bee:	ebc080e7          	jalr	-324(ra) # 80005aa6 <consputc>
    while(cons.e != cons.w &&
    80005bf2:	0a04a783          	lw	a5,160(s1)
    80005bf6:	09c4a703          	lw	a4,156(s1)
    80005bfa:	fcf71ce3          	bne	a4,a5,80005bd2 <consoleintr+0xea>
    80005bfe:	b71d                	j	80005b24 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005c00:	00240717          	auipc	a4,0x240
    80005c04:	54070713          	addi	a4,a4,1344 # 80246140 <cons>
    80005c08:	0a072783          	lw	a5,160(a4)
    80005c0c:	09c72703          	lw	a4,156(a4)
    80005c10:	f0f70ae3          	beq	a4,a5,80005b24 <consoleintr+0x3c>
      cons.e--;
    80005c14:	37fd                	addiw	a5,a5,-1
    80005c16:	00240717          	auipc	a4,0x240
    80005c1a:	5cf72523          	sw	a5,1482(a4) # 802461e0 <cons+0xa0>
      consputc(BACKSPACE);
    80005c1e:	10000513          	li	a0,256
    80005c22:	00000097          	auipc	ra,0x0
    80005c26:	e84080e7          	jalr	-380(ra) # 80005aa6 <consputc>
    80005c2a:	bded                	j	80005b24 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80005c2c:	ee048ce3          	beqz	s1,80005b24 <consoleintr+0x3c>
    80005c30:	bf21                	j	80005b48 <consoleintr+0x60>
      consputc(c);
    80005c32:	4529                	li	a0,10
    80005c34:	00000097          	auipc	ra,0x0
    80005c38:	e72080e7          	jalr	-398(ra) # 80005aa6 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80005c3c:	00240797          	auipc	a5,0x240
    80005c40:	50478793          	addi	a5,a5,1284 # 80246140 <cons>
    80005c44:	0a07a703          	lw	a4,160(a5)
    80005c48:	0017069b          	addiw	a3,a4,1
    80005c4c:	0006861b          	sext.w	a2,a3
    80005c50:	0ad7a023          	sw	a3,160(a5)
    80005c54:	07f77713          	andi	a4,a4,127
    80005c58:	97ba                	add	a5,a5,a4
    80005c5a:	4729                	li	a4,10
    80005c5c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005c60:	00240797          	auipc	a5,0x240
    80005c64:	56c7ae23          	sw	a2,1404(a5) # 802461dc <cons+0x9c>
        wakeup(&cons.r);
    80005c68:	00240517          	auipc	a0,0x240
    80005c6c:	57050513          	addi	a0,a0,1392 # 802461d8 <cons+0x98>
    80005c70:	ffffc097          	auipc	ra,0xffffc
    80005c74:	ba4080e7          	jalr	-1116(ra) # 80001814 <wakeup>
    80005c78:	b575                	j	80005b24 <consoleintr+0x3c>

0000000080005c7a <consoleinit>:

void
consoleinit(void)
{
    80005c7a:	1141                	addi	sp,sp,-16
    80005c7c:	e406                	sd	ra,8(sp)
    80005c7e:	e022                	sd	s0,0(sp)
    80005c80:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005c82:	00003597          	auipc	a1,0x3
    80005c86:	b6658593          	addi	a1,a1,-1178 # 800087e8 <syscalls+0x3c8>
    80005c8a:	00240517          	auipc	a0,0x240
    80005c8e:	4b650513          	addi	a0,a0,1206 # 80246140 <cons>
    80005c92:	00000097          	auipc	ra,0x0
    80005c96:	590080e7          	jalr	1424(ra) # 80006222 <initlock>

  uartinit();
    80005c9a:	00000097          	auipc	ra,0x0
    80005c9e:	330080e7          	jalr	816(ra) # 80005fca <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005ca2:	00233797          	auipc	a5,0x233
    80005ca6:	43e78793          	addi	a5,a5,1086 # 802390e0 <devsw>
    80005caa:	00000717          	auipc	a4,0x0
    80005cae:	ce470713          	addi	a4,a4,-796 # 8000598e <consoleread>
    80005cb2:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005cb4:	00000717          	auipc	a4,0x0
    80005cb8:	c7870713          	addi	a4,a4,-904 # 8000592c <consolewrite>
    80005cbc:	ef98                	sd	a4,24(a5)
}
    80005cbe:	60a2                	ld	ra,8(sp)
    80005cc0:	6402                	ld	s0,0(sp)
    80005cc2:	0141                	addi	sp,sp,16
    80005cc4:	8082                	ret

0000000080005cc6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005cc6:	7179                	addi	sp,sp,-48
    80005cc8:	f406                	sd	ra,40(sp)
    80005cca:	f022                	sd	s0,32(sp)
    80005ccc:	ec26                	sd	s1,24(sp)
    80005cce:	e84a                	sd	s2,16(sp)
    80005cd0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005cd2:	c219                	beqz	a2,80005cd8 <printint+0x12>
    80005cd4:	08054663          	bltz	a0,80005d60 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005cd8:	2501                	sext.w	a0,a0
    80005cda:	4881                	li	a7,0
    80005cdc:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005ce0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005ce2:	2581                	sext.w	a1,a1
    80005ce4:	00003617          	auipc	a2,0x3
    80005ce8:	b3460613          	addi	a2,a2,-1228 # 80008818 <digits>
    80005cec:	883a                	mv	a6,a4
    80005cee:	2705                	addiw	a4,a4,1
    80005cf0:	02b577bb          	remuw	a5,a0,a1
    80005cf4:	1782                	slli	a5,a5,0x20
    80005cf6:	9381                	srli	a5,a5,0x20
    80005cf8:	97b2                	add	a5,a5,a2
    80005cfa:	0007c783          	lbu	a5,0(a5)
    80005cfe:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005d02:	0005079b          	sext.w	a5,a0
    80005d06:	02b5553b          	divuw	a0,a0,a1
    80005d0a:	0685                	addi	a3,a3,1
    80005d0c:	feb7f0e3          	bgeu	a5,a1,80005cec <printint+0x26>

  if(sign)
    80005d10:	00088b63          	beqz	a7,80005d26 <printint+0x60>
    buf[i++] = '-';
    80005d14:	fe040793          	addi	a5,s0,-32
    80005d18:	973e                	add	a4,a4,a5
    80005d1a:	02d00793          	li	a5,45
    80005d1e:	fef70823          	sb	a5,-16(a4)
    80005d22:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005d26:	02e05763          	blez	a4,80005d54 <printint+0x8e>
    80005d2a:	fd040793          	addi	a5,s0,-48
    80005d2e:	00e784b3          	add	s1,a5,a4
    80005d32:	fff78913          	addi	s2,a5,-1
    80005d36:	993a                	add	s2,s2,a4
    80005d38:	377d                	addiw	a4,a4,-1
    80005d3a:	1702                	slli	a4,a4,0x20
    80005d3c:	9301                	srli	a4,a4,0x20
    80005d3e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005d42:	fff4c503          	lbu	a0,-1(s1)
    80005d46:	00000097          	auipc	ra,0x0
    80005d4a:	d60080e7          	jalr	-672(ra) # 80005aa6 <consputc>
  while(--i >= 0)
    80005d4e:	14fd                	addi	s1,s1,-1
    80005d50:	ff2499e3          	bne	s1,s2,80005d42 <printint+0x7c>
}
    80005d54:	70a2                	ld	ra,40(sp)
    80005d56:	7402                	ld	s0,32(sp)
    80005d58:	64e2                	ld	s1,24(sp)
    80005d5a:	6942                	ld	s2,16(sp)
    80005d5c:	6145                	addi	sp,sp,48
    80005d5e:	8082                	ret
    x = -xx;
    80005d60:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005d64:	4885                	li	a7,1
    x = -xx;
    80005d66:	bf9d                	j	80005cdc <printint+0x16>

0000000080005d68 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005d68:	1101                	addi	sp,sp,-32
    80005d6a:	ec06                	sd	ra,24(sp)
    80005d6c:	e822                	sd	s0,16(sp)
    80005d6e:	e426                	sd	s1,8(sp)
    80005d70:	1000                	addi	s0,sp,32
    80005d72:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005d74:	00240797          	auipc	a5,0x240
    80005d78:	4807a623          	sw	zero,1164(a5) # 80246200 <pr+0x18>
  printf("panic: ");
    80005d7c:	00003517          	auipc	a0,0x3
    80005d80:	a7450513          	addi	a0,a0,-1420 # 800087f0 <syscalls+0x3d0>
    80005d84:	00000097          	auipc	ra,0x0
    80005d88:	02e080e7          	jalr	46(ra) # 80005db2 <printf>
  printf(s);
    80005d8c:	8526                	mv	a0,s1
    80005d8e:	00000097          	auipc	ra,0x0
    80005d92:	024080e7          	jalr	36(ra) # 80005db2 <printf>
  printf("\n");
    80005d96:	00002517          	auipc	a0,0x2
    80005d9a:	2e250513          	addi	a0,a0,738 # 80008078 <etext+0x78>
    80005d9e:	00000097          	auipc	ra,0x0
    80005da2:	014080e7          	jalr	20(ra) # 80005db2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005da6:	4785                	li	a5,1
    80005da8:	00003717          	auipc	a4,0x3
    80005dac:	26f72a23          	sw	a5,628(a4) # 8000901c <panicked>
  for(;;)
    80005db0:	a001                	j	80005db0 <panic+0x48>

0000000080005db2 <printf>:
{
    80005db2:	7131                	addi	sp,sp,-192
    80005db4:	fc86                	sd	ra,120(sp)
    80005db6:	f8a2                	sd	s0,112(sp)
    80005db8:	f4a6                	sd	s1,104(sp)
    80005dba:	f0ca                	sd	s2,96(sp)
    80005dbc:	ecce                	sd	s3,88(sp)
    80005dbe:	e8d2                	sd	s4,80(sp)
    80005dc0:	e4d6                	sd	s5,72(sp)
    80005dc2:	e0da                	sd	s6,64(sp)
    80005dc4:	fc5e                	sd	s7,56(sp)
    80005dc6:	f862                	sd	s8,48(sp)
    80005dc8:	f466                	sd	s9,40(sp)
    80005dca:	f06a                	sd	s10,32(sp)
    80005dcc:	ec6e                	sd	s11,24(sp)
    80005dce:	0100                	addi	s0,sp,128
    80005dd0:	8a2a                	mv	s4,a0
    80005dd2:	e40c                	sd	a1,8(s0)
    80005dd4:	e810                	sd	a2,16(s0)
    80005dd6:	ec14                	sd	a3,24(s0)
    80005dd8:	f018                	sd	a4,32(s0)
    80005dda:	f41c                	sd	a5,40(s0)
    80005ddc:	03043823          	sd	a6,48(s0)
    80005de0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005de4:	00240d97          	auipc	s11,0x240
    80005de8:	41cdad83          	lw	s11,1052(s11) # 80246200 <pr+0x18>
  if(locking)
    80005dec:	020d9b63          	bnez	s11,80005e22 <printf+0x70>
  if (fmt == 0)
    80005df0:	040a0263          	beqz	s4,80005e34 <printf+0x82>
  va_start(ap, fmt);
    80005df4:	00840793          	addi	a5,s0,8
    80005df8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005dfc:	000a4503          	lbu	a0,0(s4)
    80005e00:	16050263          	beqz	a0,80005f64 <printf+0x1b2>
    80005e04:	4481                	li	s1,0
    if(c != '%'){
    80005e06:	02500a93          	li	s5,37
    switch(c){
    80005e0a:	07000b13          	li	s6,112
  consputc('x');
    80005e0e:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005e10:	00003b97          	auipc	s7,0x3
    80005e14:	a08b8b93          	addi	s7,s7,-1528 # 80008818 <digits>
    switch(c){
    80005e18:	07300c93          	li	s9,115
    80005e1c:	06400c13          	li	s8,100
    80005e20:	a82d                	j	80005e5a <printf+0xa8>
    acquire(&pr.lock);
    80005e22:	00240517          	auipc	a0,0x240
    80005e26:	3c650513          	addi	a0,a0,966 # 802461e8 <pr>
    80005e2a:	00000097          	auipc	ra,0x0
    80005e2e:	488080e7          	jalr	1160(ra) # 800062b2 <acquire>
    80005e32:	bf7d                	j	80005df0 <printf+0x3e>
    panic("null fmt");
    80005e34:	00003517          	auipc	a0,0x3
    80005e38:	9cc50513          	addi	a0,a0,-1588 # 80008800 <syscalls+0x3e0>
    80005e3c:	00000097          	auipc	ra,0x0
    80005e40:	f2c080e7          	jalr	-212(ra) # 80005d68 <panic>
      consputc(c);
    80005e44:	00000097          	auipc	ra,0x0
    80005e48:	c62080e7          	jalr	-926(ra) # 80005aa6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005e4c:	2485                	addiw	s1,s1,1
    80005e4e:	009a07b3          	add	a5,s4,s1
    80005e52:	0007c503          	lbu	a0,0(a5)
    80005e56:	10050763          	beqz	a0,80005f64 <printf+0x1b2>
    if(c != '%'){
    80005e5a:	ff5515e3          	bne	a0,s5,80005e44 <printf+0x92>
    c = fmt[++i] & 0xff;
    80005e5e:	2485                	addiw	s1,s1,1
    80005e60:	009a07b3          	add	a5,s4,s1
    80005e64:	0007c783          	lbu	a5,0(a5)
    80005e68:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80005e6c:	cfe5                	beqz	a5,80005f64 <printf+0x1b2>
    switch(c){
    80005e6e:	05678a63          	beq	a5,s6,80005ec2 <printf+0x110>
    80005e72:	02fb7663          	bgeu	s6,a5,80005e9e <printf+0xec>
    80005e76:	09978963          	beq	a5,s9,80005f08 <printf+0x156>
    80005e7a:	07800713          	li	a4,120
    80005e7e:	0ce79863          	bne	a5,a4,80005f4e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80005e82:	f8843783          	ld	a5,-120(s0)
    80005e86:	00878713          	addi	a4,a5,8
    80005e8a:	f8e43423          	sd	a4,-120(s0)
    80005e8e:	4605                	li	a2,1
    80005e90:	85ea                	mv	a1,s10
    80005e92:	4388                	lw	a0,0(a5)
    80005e94:	00000097          	auipc	ra,0x0
    80005e98:	e32080e7          	jalr	-462(ra) # 80005cc6 <printint>
      break;
    80005e9c:	bf45                	j	80005e4c <printf+0x9a>
    switch(c){
    80005e9e:	0b578263          	beq	a5,s5,80005f42 <printf+0x190>
    80005ea2:	0b879663          	bne	a5,s8,80005f4e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80005ea6:	f8843783          	ld	a5,-120(s0)
    80005eaa:	00878713          	addi	a4,a5,8
    80005eae:	f8e43423          	sd	a4,-120(s0)
    80005eb2:	4605                	li	a2,1
    80005eb4:	45a9                	li	a1,10
    80005eb6:	4388                	lw	a0,0(a5)
    80005eb8:	00000097          	auipc	ra,0x0
    80005ebc:	e0e080e7          	jalr	-498(ra) # 80005cc6 <printint>
      break;
    80005ec0:	b771                	j	80005e4c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005ec2:	f8843783          	ld	a5,-120(s0)
    80005ec6:	00878713          	addi	a4,a5,8
    80005eca:	f8e43423          	sd	a4,-120(s0)
    80005ece:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005ed2:	03000513          	li	a0,48
    80005ed6:	00000097          	auipc	ra,0x0
    80005eda:	bd0080e7          	jalr	-1072(ra) # 80005aa6 <consputc>
  consputc('x');
    80005ede:	07800513          	li	a0,120
    80005ee2:	00000097          	auipc	ra,0x0
    80005ee6:	bc4080e7          	jalr	-1084(ra) # 80005aa6 <consputc>
    80005eea:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005eec:	03c9d793          	srli	a5,s3,0x3c
    80005ef0:	97de                	add	a5,a5,s7
    80005ef2:	0007c503          	lbu	a0,0(a5)
    80005ef6:	00000097          	auipc	ra,0x0
    80005efa:	bb0080e7          	jalr	-1104(ra) # 80005aa6 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005efe:	0992                	slli	s3,s3,0x4
    80005f00:	397d                	addiw	s2,s2,-1
    80005f02:	fe0915e3          	bnez	s2,80005eec <printf+0x13a>
    80005f06:	b799                	j	80005e4c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005f08:	f8843783          	ld	a5,-120(s0)
    80005f0c:	00878713          	addi	a4,a5,8
    80005f10:	f8e43423          	sd	a4,-120(s0)
    80005f14:	0007b903          	ld	s2,0(a5)
    80005f18:	00090e63          	beqz	s2,80005f34 <printf+0x182>
      for(; *s; s++)
    80005f1c:	00094503          	lbu	a0,0(s2)
    80005f20:	d515                	beqz	a0,80005e4c <printf+0x9a>
        consputc(*s);
    80005f22:	00000097          	auipc	ra,0x0
    80005f26:	b84080e7          	jalr	-1148(ra) # 80005aa6 <consputc>
      for(; *s; s++)
    80005f2a:	0905                	addi	s2,s2,1
    80005f2c:	00094503          	lbu	a0,0(s2)
    80005f30:	f96d                	bnez	a0,80005f22 <printf+0x170>
    80005f32:	bf29                	j	80005e4c <printf+0x9a>
        s = "(null)";
    80005f34:	00003917          	auipc	s2,0x3
    80005f38:	8c490913          	addi	s2,s2,-1852 # 800087f8 <syscalls+0x3d8>
      for(; *s; s++)
    80005f3c:	02800513          	li	a0,40
    80005f40:	b7cd                	j	80005f22 <printf+0x170>
      consputc('%');
    80005f42:	8556                	mv	a0,s5
    80005f44:	00000097          	auipc	ra,0x0
    80005f48:	b62080e7          	jalr	-1182(ra) # 80005aa6 <consputc>
      break;
    80005f4c:	b701                	j	80005e4c <printf+0x9a>
      consputc('%');
    80005f4e:	8556                	mv	a0,s5
    80005f50:	00000097          	auipc	ra,0x0
    80005f54:	b56080e7          	jalr	-1194(ra) # 80005aa6 <consputc>
      consputc(c);
    80005f58:	854a                	mv	a0,s2
    80005f5a:	00000097          	auipc	ra,0x0
    80005f5e:	b4c080e7          	jalr	-1204(ra) # 80005aa6 <consputc>
      break;
    80005f62:	b5ed                	j	80005e4c <printf+0x9a>
  if(locking)
    80005f64:	020d9163          	bnez	s11,80005f86 <printf+0x1d4>
}
    80005f68:	70e6                	ld	ra,120(sp)
    80005f6a:	7446                	ld	s0,112(sp)
    80005f6c:	74a6                	ld	s1,104(sp)
    80005f6e:	7906                	ld	s2,96(sp)
    80005f70:	69e6                	ld	s3,88(sp)
    80005f72:	6a46                	ld	s4,80(sp)
    80005f74:	6aa6                	ld	s5,72(sp)
    80005f76:	6b06                	ld	s6,64(sp)
    80005f78:	7be2                	ld	s7,56(sp)
    80005f7a:	7c42                	ld	s8,48(sp)
    80005f7c:	7ca2                	ld	s9,40(sp)
    80005f7e:	7d02                	ld	s10,32(sp)
    80005f80:	6de2                	ld	s11,24(sp)
    80005f82:	6129                	addi	sp,sp,192
    80005f84:	8082                	ret
    release(&pr.lock);
    80005f86:	00240517          	auipc	a0,0x240
    80005f8a:	26250513          	addi	a0,a0,610 # 802461e8 <pr>
    80005f8e:	00000097          	auipc	ra,0x0
    80005f92:	3d8080e7          	jalr	984(ra) # 80006366 <release>
}
    80005f96:	bfc9                	j	80005f68 <printf+0x1b6>

0000000080005f98 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005f98:	1101                	addi	sp,sp,-32
    80005f9a:	ec06                	sd	ra,24(sp)
    80005f9c:	e822                	sd	s0,16(sp)
    80005f9e:	e426                	sd	s1,8(sp)
    80005fa0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005fa2:	00240497          	auipc	s1,0x240
    80005fa6:	24648493          	addi	s1,s1,582 # 802461e8 <pr>
    80005faa:	00003597          	auipc	a1,0x3
    80005fae:	86658593          	addi	a1,a1,-1946 # 80008810 <syscalls+0x3f0>
    80005fb2:	8526                	mv	a0,s1
    80005fb4:	00000097          	auipc	ra,0x0
    80005fb8:	26e080e7          	jalr	622(ra) # 80006222 <initlock>
  pr.locking = 1;
    80005fbc:	4785                	li	a5,1
    80005fbe:	cc9c                	sw	a5,24(s1)
}
    80005fc0:	60e2                	ld	ra,24(sp)
    80005fc2:	6442                	ld	s0,16(sp)
    80005fc4:	64a2                	ld	s1,8(sp)
    80005fc6:	6105                	addi	sp,sp,32
    80005fc8:	8082                	ret

0000000080005fca <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005fca:	1141                	addi	sp,sp,-16
    80005fcc:	e406                	sd	ra,8(sp)
    80005fce:	e022                	sd	s0,0(sp)
    80005fd0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005fd2:	100007b7          	lui	a5,0x10000
    80005fd6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005fda:	f8000713          	li	a4,-128
    80005fde:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005fe2:	470d                	li	a4,3
    80005fe4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005fe8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005fec:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005ff0:	469d                	li	a3,7
    80005ff2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005ff6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005ffa:	00003597          	auipc	a1,0x3
    80005ffe:	83658593          	addi	a1,a1,-1994 # 80008830 <digits+0x18>
    80006002:	00240517          	auipc	a0,0x240
    80006006:	20650513          	addi	a0,a0,518 # 80246208 <uart_tx_lock>
    8000600a:	00000097          	auipc	ra,0x0
    8000600e:	218080e7          	jalr	536(ra) # 80006222 <initlock>
}
    80006012:	60a2                	ld	ra,8(sp)
    80006014:	6402                	ld	s0,0(sp)
    80006016:	0141                	addi	sp,sp,16
    80006018:	8082                	ret

000000008000601a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000601a:	1101                	addi	sp,sp,-32
    8000601c:	ec06                	sd	ra,24(sp)
    8000601e:	e822                	sd	s0,16(sp)
    80006020:	e426                	sd	s1,8(sp)
    80006022:	1000                	addi	s0,sp,32
    80006024:	84aa                	mv	s1,a0
  push_off();
    80006026:	00000097          	auipc	ra,0x0
    8000602a:	240080e7          	jalr	576(ra) # 80006266 <push_off>

  if(panicked){
    8000602e:	00003797          	auipc	a5,0x3
    80006032:	fee7a783          	lw	a5,-18(a5) # 8000901c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006036:	10000737          	lui	a4,0x10000
  if(panicked){
    8000603a:	c391                	beqz	a5,8000603e <uartputc_sync+0x24>
    for(;;)
    8000603c:	a001                	j	8000603c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000603e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80006042:	0ff7f793          	andi	a5,a5,255
    80006046:	0207f793          	andi	a5,a5,32
    8000604a:	dbf5                	beqz	a5,8000603e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000604c:	0ff4f793          	andi	a5,s1,255
    80006050:	10000737          	lui	a4,0x10000
    80006054:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80006058:	00000097          	auipc	ra,0x0
    8000605c:	2ae080e7          	jalr	686(ra) # 80006306 <pop_off>
}
    80006060:	60e2                	ld	ra,24(sp)
    80006062:	6442                	ld	s0,16(sp)
    80006064:	64a2                	ld	s1,8(sp)
    80006066:	6105                	addi	sp,sp,32
    80006068:	8082                	ret

000000008000606a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000606a:	00003717          	auipc	a4,0x3
    8000606e:	fb673703          	ld	a4,-74(a4) # 80009020 <uart_tx_r>
    80006072:	00003797          	auipc	a5,0x3
    80006076:	fb67b783          	ld	a5,-74(a5) # 80009028 <uart_tx_w>
    8000607a:	06e78c63          	beq	a5,a4,800060f2 <uartstart+0x88>
{
    8000607e:	7139                	addi	sp,sp,-64
    80006080:	fc06                	sd	ra,56(sp)
    80006082:	f822                	sd	s0,48(sp)
    80006084:	f426                	sd	s1,40(sp)
    80006086:	f04a                	sd	s2,32(sp)
    80006088:	ec4e                	sd	s3,24(sp)
    8000608a:	e852                	sd	s4,16(sp)
    8000608c:	e456                	sd	s5,8(sp)
    8000608e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006090:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006094:	00240a17          	auipc	s4,0x240
    80006098:	174a0a13          	addi	s4,s4,372 # 80246208 <uart_tx_lock>
    uart_tx_r += 1;
    8000609c:	00003497          	auipc	s1,0x3
    800060a0:	f8448493          	addi	s1,s1,-124 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800060a4:	00003997          	auipc	s3,0x3
    800060a8:	f8498993          	addi	s3,s3,-124 # 80009028 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800060ac:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800060b0:	0ff7f793          	andi	a5,a5,255
    800060b4:	0207f793          	andi	a5,a5,32
    800060b8:	c785                	beqz	a5,800060e0 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800060ba:	01f77793          	andi	a5,a4,31
    800060be:	97d2                	add	a5,a5,s4
    800060c0:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800060c4:	0705                	addi	a4,a4,1
    800060c6:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800060c8:	8526                	mv	a0,s1
    800060ca:	ffffb097          	auipc	ra,0xffffb
    800060ce:	74a080e7          	jalr	1866(ra) # 80001814 <wakeup>
    
    WriteReg(THR, c);
    800060d2:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800060d6:	6098                	ld	a4,0(s1)
    800060d8:	0009b783          	ld	a5,0(s3)
    800060dc:	fce798e3          	bne	a5,a4,800060ac <uartstart+0x42>
  }
}
    800060e0:	70e2                	ld	ra,56(sp)
    800060e2:	7442                	ld	s0,48(sp)
    800060e4:	74a2                	ld	s1,40(sp)
    800060e6:	7902                	ld	s2,32(sp)
    800060e8:	69e2                	ld	s3,24(sp)
    800060ea:	6a42                	ld	s4,16(sp)
    800060ec:	6aa2                	ld	s5,8(sp)
    800060ee:	6121                	addi	sp,sp,64
    800060f0:	8082                	ret
    800060f2:	8082                	ret

00000000800060f4 <uartputc>:
{
    800060f4:	7179                	addi	sp,sp,-48
    800060f6:	f406                	sd	ra,40(sp)
    800060f8:	f022                	sd	s0,32(sp)
    800060fa:	ec26                	sd	s1,24(sp)
    800060fc:	e84a                	sd	s2,16(sp)
    800060fe:	e44e                	sd	s3,8(sp)
    80006100:	e052                	sd	s4,0(sp)
    80006102:	1800                	addi	s0,sp,48
    80006104:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80006106:	00240517          	auipc	a0,0x240
    8000610a:	10250513          	addi	a0,a0,258 # 80246208 <uart_tx_lock>
    8000610e:	00000097          	auipc	ra,0x0
    80006112:	1a4080e7          	jalr	420(ra) # 800062b2 <acquire>
  if(panicked){
    80006116:	00003797          	auipc	a5,0x3
    8000611a:	f067a783          	lw	a5,-250(a5) # 8000901c <panicked>
    8000611e:	c391                	beqz	a5,80006122 <uartputc+0x2e>
    for(;;)
    80006120:	a001                	j	80006120 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006122:	00003797          	auipc	a5,0x3
    80006126:	f067b783          	ld	a5,-250(a5) # 80009028 <uart_tx_w>
    8000612a:	00003717          	auipc	a4,0x3
    8000612e:	ef673703          	ld	a4,-266(a4) # 80009020 <uart_tx_r>
    80006132:	02070713          	addi	a4,a4,32
    80006136:	02f71b63          	bne	a4,a5,8000616c <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000613a:	00240a17          	auipc	s4,0x240
    8000613e:	0cea0a13          	addi	s4,s4,206 # 80246208 <uart_tx_lock>
    80006142:	00003497          	auipc	s1,0x3
    80006146:	ede48493          	addi	s1,s1,-290 # 80009020 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000614a:	00003917          	auipc	s2,0x3
    8000614e:	ede90913          	addi	s2,s2,-290 # 80009028 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80006152:	85d2                	mv	a1,s4
    80006154:	8526                	mv	a0,s1
    80006156:	ffffb097          	auipc	ra,0xffffb
    8000615a:	532080e7          	jalr	1330(ra) # 80001688 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000615e:	00093783          	ld	a5,0(s2)
    80006162:	6098                	ld	a4,0(s1)
    80006164:	02070713          	addi	a4,a4,32
    80006168:	fef705e3          	beq	a4,a5,80006152 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000616c:	00240497          	auipc	s1,0x240
    80006170:	09c48493          	addi	s1,s1,156 # 80246208 <uart_tx_lock>
    80006174:	01f7f713          	andi	a4,a5,31
    80006178:	9726                	add	a4,a4,s1
    8000617a:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    8000617e:	0785                	addi	a5,a5,1
    80006180:	00003717          	auipc	a4,0x3
    80006184:	eaf73423          	sd	a5,-344(a4) # 80009028 <uart_tx_w>
      uartstart();
    80006188:	00000097          	auipc	ra,0x0
    8000618c:	ee2080e7          	jalr	-286(ra) # 8000606a <uartstart>
      release(&uart_tx_lock);
    80006190:	8526                	mv	a0,s1
    80006192:	00000097          	auipc	ra,0x0
    80006196:	1d4080e7          	jalr	468(ra) # 80006366 <release>
}
    8000619a:	70a2                	ld	ra,40(sp)
    8000619c:	7402                	ld	s0,32(sp)
    8000619e:	64e2                	ld	s1,24(sp)
    800061a0:	6942                	ld	s2,16(sp)
    800061a2:	69a2                	ld	s3,8(sp)
    800061a4:	6a02                	ld	s4,0(sp)
    800061a6:	6145                	addi	sp,sp,48
    800061a8:	8082                	ret

00000000800061aa <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800061aa:	1141                	addi	sp,sp,-16
    800061ac:	e422                	sd	s0,8(sp)
    800061ae:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800061b0:	100007b7          	lui	a5,0x10000
    800061b4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800061b8:	8b85                	andi	a5,a5,1
    800061ba:	cb91                	beqz	a5,800061ce <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800061bc:	100007b7          	lui	a5,0x10000
    800061c0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800061c4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800061c8:	6422                	ld	s0,8(sp)
    800061ca:	0141                	addi	sp,sp,16
    800061cc:	8082                	ret
    return -1;
    800061ce:	557d                	li	a0,-1
    800061d0:	bfe5                	j	800061c8 <uartgetc+0x1e>

00000000800061d2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800061d2:	1101                	addi	sp,sp,-32
    800061d4:	ec06                	sd	ra,24(sp)
    800061d6:	e822                	sd	s0,16(sp)
    800061d8:	e426                	sd	s1,8(sp)
    800061da:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800061dc:	54fd                	li	s1,-1
    int c = uartgetc();
    800061de:	00000097          	auipc	ra,0x0
    800061e2:	fcc080e7          	jalr	-52(ra) # 800061aa <uartgetc>
    if(c == -1)
    800061e6:	00950763          	beq	a0,s1,800061f4 <uartintr+0x22>
      break;
    consoleintr(c);
    800061ea:	00000097          	auipc	ra,0x0
    800061ee:	8fe080e7          	jalr	-1794(ra) # 80005ae8 <consoleintr>
  while(1){
    800061f2:	b7f5                	j	800061de <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800061f4:	00240497          	auipc	s1,0x240
    800061f8:	01448493          	addi	s1,s1,20 # 80246208 <uart_tx_lock>
    800061fc:	8526                	mv	a0,s1
    800061fe:	00000097          	auipc	ra,0x0
    80006202:	0b4080e7          	jalr	180(ra) # 800062b2 <acquire>
  uartstart();
    80006206:	00000097          	auipc	ra,0x0
    8000620a:	e64080e7          	jalr	-412(ra) # 8000606a <uartstart>
  release(&uart_tx_lock);
    8000620e:	8526                	mv	a0,s1
    80006210:	00000097          	auipc	ra,0x0
    80006214:	156080e7          	jalr	342(ra) # 80006366 <release>
}
    80006218:	60e2                	ld	ra,24(sp)
    8000621a:	6442                	ld	s0,16(sp)
    8000621c:	64a2                	ld	s1,8(sp)
    8000621e:	6105                	addi	sp,sp,32
    80006220:	8082                	ret

0000000080006222 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80006222:	1141                	addi	sp,sp,-16
    80006224:	e422                	sd	s0,8(sp)
    80006226:	0800                	addi	s0,sp,16
  lk->name = name;
    80006228:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000622a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000622e:	00053823          	sd	zero,16(a0)
}
    80006232:	6422                	ld	s0,8(sp)
    80006234:	0141                	addi	sp,sp,16
    80006236:	8082                	ret

0000000080006238 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006238:	411c                	lw	a5,0(a0)
    8000623a:	e399                	bnez	a5,80006240 <holding+0x8>
    8000623c:	4501                	li	a0,0
  return r;
}
    8000623e:	8082                	ret
{
    80006240:	1101                	addi	sp,sp,-32
    80006242:	ec06                	sd	ra,24(sp)
    80006244:	e822                	sd	s0,16(sp)
    80006246:	e426                	sd	s1,8(sp)
    80006248:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000624a:	6904                	ld	s1,16(a0)
    8000624c:	ffffb097          	auipc	ra,0xffffb
    80006250:	d64080e7          	jalr	-668(ra) # 80000fb0 <mycpu>
    80006254:	40a48533          	sub	a0,s1,a0
    80006258:	00153513          	seqz	a0,a0
}
    8000625c:	60e2                	ld	ra,24(sp)
    8000625e:	6442                	ld	s0,16(sp)
    80006260:	64a2                	ld	s1,8(sp)
    80006262:	6105                	addi	sp,sp,32
    80006264:	8082                	ret

0000000080006266 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80006266:	1101                	addi	sp,sp,-32
    80006268:	ec06                	sd	ra,24(sp)
    8000626a:	e822                	sd	s0,16(sp)
    8000626c:	e426                	sd	s1,8(sp)
    8000626e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006270:	100024f3          	csrr	s1,sstatus
    80006274:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80006278:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000627a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    8000627e:	ffffb097          	auipc	ra,0xffffb
    80006282:	d32080e7          	jalr	-718(ra) # 80000fb0 <mycpu>
    80006286:	5d3c                	lw	a5,120(a0)
    80006288:	cf89                	beqz	a5,800062a2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000628a:	ffffb097          	auipc	ra,0xffffb
    8000628e:	d26080e7          	jalr	-730(ra) # 80000fb0 <mycpu>
    80006292:	5d3c                	lw	a5,120(a0)
    80006294:	2785                	addiw	a5,a5,1
    80006296:	dd3c                	sw	a5,120(a0)
}
    80006298:	60e2                	ld	ra,24(sp)
    8000629a:	6442                	ld	s0,16(sp)
    8000629c:	64a2                	ld	s1,8(sp)
    8000629e:	6105                	addi	sp,sp,32
    800062a0:	8082                	ret
    mycpu()->intena = old;
    800062a2:	ffffb097          	auipc	ra,0xffffb
    800062a6:	d0e080e7          	jalr	-754(ra) # 80000fb0 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800062aa:	8085                	srli	s1,s1,0x1
    800062ac:	8885                	andi	s1,s1,1
    800062ae:	dd64                	sw	s1,124(a0)
    800062b0:	bfe9                	j	8000628a <push_off+0x24>

00000000800062b2 <acquire>:
{
    800062b2:	1101                	addi	sp,sp,-32
    800062b4:	ec06                	sd	ra,24(sp)
    800062b6:	e822                	sd	s0,16(sp)
    800062b8:	e426                	sd	s1,8(sp)
    800062ba:	1000                	addi	s0,sp,32
    800062bc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800062be:	00000097          	auipc	ra,0x0
    800062c2:	fa8080e7          	jalr	-88(ra) # 80006266 <push_off>
  if(holding(lk))
    800062c6:	8526                	mv	a0,s1
    800062c8:	00000097          	auipc	ra,0x0
    800062cc:	f70080e7          	jalr	-144(ra) # 80006238 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800062d0:	4705                	li	a4,1
  if(holding(lk))
    800062d2:	e115                	bnez	a0,800062f6 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800062d4:	87ba                	mv	a5,a4
    800062d6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800062da:	2781                	sext.w	a5,a5
    800062dc:	ffe5                	bnez	a5,800062d4 <acquire+0x22>
  __sync_synchronize();
    800062de:	0ff0000f          	fence
  lk->cpu = mycpu();
    800062e2:	ffffb097          	auipc	ra,0xffffb
    800062e6:	cce080e7          	jalr	-818(ra) # 80000fb0 <mycpu>
    800062ea:	e888                	sd	a0,16(s1)
}
    800062ec:	60e2                	ld	ra,24(sp)
    800062ee:	6442                	ld	s0,16(sp)
    800062f0:	64a2                	ld	s1,8(sp)
    800062f2:	6105                	addi	sp,sp,32
    800062f4:	8082                	ret
    panic("acquire");
    800062f6:	00002517          	auipc	a0,0x2
    800062fa:	54250513          	addi	a0,a0,1346 # 80008838 <digits+0x20>
    800062fe:	00000097          	auipc	ra,0x0
    80006302:	a6a080e7          	jalr	-1430(ra) # 80005d68 <panic>

0000000080006306 <pop_off>:

void
pop_off(void)
{
    80006306:	1141                	addi	sp,sp,-16
    80006308:	e406                	sd	ra,8(sp)
    8000630a:	e022                	sd	s0,0(sp)
    8000630c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000630e:	ffffb097          	auipc	ra,0xffffb
    80006312:	ca2080e7          	jalr	-862(ra) # 80000fb0 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006316:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000631a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000631c:	e78d                	bnez	a5,80006346 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    8000631e:	5d3c                	lw	a5,120(a0)
    80006320:	02f05b63          	blez	a5,80006356 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80006324:	37fd                	addiw	a5,a5,-1
    80006326:	0007871b          	sext.w	a4,a5
    8000632a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    8000632c:	eb09                	bnez	a4,8000633e <pop_off+0x38>
    8000632e:	5d7c                	lw	a5,124(a0)
    80006330:	c799                	beqz	a5,8000633e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006332:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006336:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000633a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    8000633e:	60a2                	ld	ra,8(sp)
    80006340:	6402                	ld	s0,0(sp)
    80006342:	0141                	addi	sp,sp,16
    80006344:	8082                	ret
    panic("pop_off - interruptible");
    80006346:	00002517          	auipc	a0,0x2
    8000634a:	4fa50513          	addi	a0,a0,1274 # 80008840 <digits+0x28>
    8000634e:	00000097          	auipc	ra,0x0
    80006352:	a1a080e7          	jalr	-1510(ra) # 80005d68 <panic>
    panic("pop_off");
    80006356:	00002517          	auipc	a0,0x2
    8000635a:	50250513          	addi	a0,a0,1282 # 80008858 <digits+0x40>
    8000635e:	00000097          	auipc	ra,0x0
    80006362:	a0a080e7          	jalr	-1526(ra) # 80005d68 <panic>

0000000080006366 <release>:
{
    80006366:	1101                	addi	sp,sp,-32
    80006368:	ec06                	sd	ra,24(sp)
    8000636a:	e822                	sd	s0,16(sp)
    8000636c:	e426                	sd	s1,8(sp)
    8000636e:	1000                	addi	s0,sp,32
    80006370:	84aa                	mv	s1,a0
  if(!holding(lk))
    80006372:	00000097          	auipc	ra,0x0
    80006376:	ec6080e7          	jalr	-314(ra) # 80006238 <holding>
    8000637a:	c115                	beqz	a0,8000639e <release+0x38>
  lk->cpu = 0;
    8000637c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80006380:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80006384:	0f50000f          	fence	iorw,ow
    80006388:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000638c:	00000097          	auipc	ra,0x0
    80006390:	f7a080e7          	jalr	-134(ra) # 80006306 <pop_off>
}
    80006394:	60e2                	ld	ra,24(sp)
    80006396:	6442                	ld	s0,16(sp)
    80006398:	64a2                	ld	s1,8(sp)
    8000639a:	6105                	addi	sp,sp,32
    8000639c:	8082                	ret
    panic("release");
    8000639e:	00002517          	auipc	a0,0x2
    800063a2:	4c250513          	addi	a0,a0,1218 # 80008860 <digits+0x48>
    800063a6:	00000097          	auipc	ra,0x0
    800063aa:	9c2080e7          	jalr	-1598(ra) # 80005d68 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
