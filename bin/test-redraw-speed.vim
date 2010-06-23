$ cat test-redraw-speed.vim

" Benchmark vim's redrawing speed
let i = 0
while i < 2000
  1
  redraw
  $
  redraw
  let i = i + 1
endwhile
qa! 
