// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;


//ενα struct with spinlock & refCounter
//το refCounter ειναι ενας πινακας που δειχνει 
//για καθε σελιδα τον αριθμο των διεργασιων που δειχνον
//σε αυτην
struct {
  struct spinlock lock;
  int refCounter[PHYSTOP/PGSIZE];
}RefTable;



void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
  {

    //το αρχικοποιηοθμε σε 1 ωστε να μην υπαρχει προβλημα με την kfree
    //διοτι εχει αλλαξει η kfree ωστε να διαγραφει σελιδες που δεν δειχνει καμια
    //διεργασια σε αυτες
    RefTable.refCounter[ (uint64)p/PGSIZE] = 1;
    kfree(p);
  }
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{


  //πρεπει να μειωνετε το ρεφερενσ καουντερρ

  
  struct run *r;

  r = (struct run*)pa;
  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  //οταν καλουμε την kfree 
  //εχουμε για καθε σελιδα εναν counter μειωνουμε αυτο το counter 
  //αν ειναι >=1
  int count;
  acquire(&RefTable.lock);
  count = RefTable.refCounter[(uint64)r/PGSIZE];
  

  if(count < 1)
    panic("error kfree");

  RefTable.refCounter[ (uint64)r/PGSIZE]--;
  count = RefTable.refCounter[ (uint64)r/PGSIZE];

  release(&RefTable.lock);

  //Αν μετα την μειωση ειναι θετικος ακομα αριθμος και οχι ισος με το 0
  //τοτε δεν διαγραφουμε την σελιδα καθως ακομη υπαρχουν αλλη ή αλλες διεργγασιες
  //που δειχνουν σε αυτην
  if( count > 0)
    return;

  //Αν ειναι ισο με μηδεν τοτε δεν δειχνει καμια αλλη διεργασια σε αυτην επομενως την διαγραφουμε

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}


//Η συναρτηση αυτη αυξανει το counter  της συγκεκριμενης σελιδας pa καθως δειχνει 
//+1 διεργασια σε αυτην
void 
RefPlus( uint64 pa)
{
  acquire(&RefTable.lock);
  
  if( pa > PHYSTOP)
    panic("ERROR refplus");

  if( RefTable.refCounter[ pa/PGSIZE] < 1)
    panic("Error refplus");
  RefTable.refCounter[ pa/PGSIZE]++;

  release(&RefTable.lock);
}


// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
  {
    kmem.freelist = r->next;
    acquire(&RefTable.lock);
    
    //οταν δημιουργω μια καινουρια σελιδα τοτε 
    //αρχικοποιω τον μετρητη της σε 1
    RefTable.refCounter[ (uint64)r/PGSIZE] = 1;
    release(&RefTable.lock);
  }
  release(&kmem.lock);

 

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
