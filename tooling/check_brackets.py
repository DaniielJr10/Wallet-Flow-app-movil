from pathlib import Path
p=Path(r'lib/pantallas/herramientass/calendario.dart')
s=p.read_text()
opening='([{' 
pairs={'(':')','[':']','{':'}'}
stack=[]
for i,ch in enumerate(s):
    if ch in opening:
        stack.append((ch,i))
    elif ch in pairs.values():
        if not stack:
            print('Unmatched closing',ch,'at index',i)
            break
        last,idx=stack[-1]
        if pairs[last]==ch:
            stack.pop()
        else:
            print('Mismatched',last,'opened at',idx,'but closed by',ch,'at',i)
            break
else:
    if stack:
        print('Unclosed openings:')
        for ch,idx in stack[-20:]:
            line=s.count('\n',0,idx)+1
            col=idx - s.rfind('\n',0,idx)
            print(f"{ch} at index {idx} line {line} col {col}")
    else:
        print('All balanced')
