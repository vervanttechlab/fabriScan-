const CATS={
 barong:{name:'Barong',icon:'checkroom',tx:'pina',desc:'Sheer and crisp fabrics for the barong Tagalog.'},
 formal:{name:'Formal wear',icon:'work',tx:'wool',desc:'Suiting and shirting fabrics for formal events.'},
 gowns:{name:'Gowns',icon:'styler',tx:'satin',desc:'Fabrics with sheen, drape and volume for gowns.'},
 filipiniana:{name:'Filipiniana',icon:'auto_awesome',tx:'inabel',desc:'Heritage and handwoven fabrics for Filipiniana.'}
};
const N='natural',S='synthetic',B='blend';
const F=[
 ['pina','Piña','Piña cloth',['barong','filipiniana'],[['Pineapple-leaf fiber',N]],'A fine, sheer cloth handwoven from pineapple-leaf fibers. It is light, slightly stiff, and has a soft natural sheen.',['See-through when held up to light','Crisp, slightly stiff feel','Fine, slightly uneven threads'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['pinaseda','Piña-seda','Piña-silk',['barong'],[['Pineapple-leaf fiber + silk',B]],'Piña blended with silk. Softer and smoother than pure piña, with more drape and a brighter sheen.',['Softer and less stiff than piña','Brighter, silky sheen','Even, smooth threads'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['jusi','Jusi','Husi',['barong','filipiniana'],[['Silk',N],['Abacá',N],['Polyester',S]],'A sheer, light fabric often embroidered for barong. Older jusi was silk or abacá; most modern jusi is polyester or a blend.',['Sheer, but smoother than piña','Often has woven stripes or embroidery','Even, machine-regular threads'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['organza','Organza','',['barong'],[['Silk',N],['Polyester',S]],'A sheer, crisp plain-weave fabric that holds its shape. Used for barong, sleeves and gown layers.',['Sheer and very crisp','Holds a stiff shape','Light shimmer'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['cocoon','Cocoon','Gusot-mayaman',['barong'],[['Polyester',S],['Polyester blend',B]],'A light fabric with a built-in crinkled texture, so it looks fine even when wrinkled. Popular for everyday barong.',['Crinkled, wrinkled-look texture','Opaque or semi-sheer','Soft and light'],'syn',[1,'Usually not needed. If you must, low, up to 110 °C']],
 ['wool','Wool suiting','',['formal'],[['Wool',N],['Wool blend',B]],'A smooth, firm woven wool used for suits and slacks. It drapes well and resists wrinkles.',['Fine diagonal twill lines','Warm, slightly springy feel','Matte or low sheen'],'wool',[2,'Medium, up to 150 °C, with steam and a press cloth']],
 ['polyvis','Poly-viscose','Tropical suiting',['formal'],[['Polyester + viscose rayon',B]],'A light suiting fabric that mixes polyester and viscose rayon. Cooler than wool and common in local tailoring.',['Smooth, light suiting','Slight sheen','Springs back after crushing'],'syn',[1,'Low, up to 110 °C, on the reverse side']],
 ['cotton','Cotton','Poplin, broadcloth',['formal'],[['Cotton',N]],'A smooth, tightly woven cotton used for dress shirts. Breathable and easy to iron.',['Tight, fine weave','Soft, matte surface','Creases when crushed'],'cot',[3,'Hot, up to 200 °C, while slightly damp']],
 ['linen','Linen','',['formal'],[['Flax',N]],'A woven fabric made from flax. It is cool, strong, and wrinkles easily.',['Uneven, slubby threads','Crisp, cool feel','Wrinkles quickly'],'cot',[3,'Hot, up to 200 °C, while slightly damp']],
 ['crepe','Crepe','',['formal'],[['Polyester',S],['Silk',N],['Wool',N]],'A fabric with a fine pebbly surface that drapes softly. Used for dresses, blouses and suits.',['Fine pebbly surface','Matte, grainy look','Drapes softly'],'del',[1,'Low, up to 110 °C, on the reverse side']],
 ['satin','Satin','',['gowns'],[['Polyester',S],['Silk',N]],'A smooth weave with a glossy face and a dull back. Common for gowns and linings.',['Glossy front, dull back','Very smooth and slippery','Reflects light as it drapes'],'del',[1,'Low, up to 110 °C, on the dull side only']],
 ['chiffon','Chiffon','',['gowns'],[['Polyester',S],['Silk',N]],'A very light, sheer, floaty fabric used for gown layers and sleeves.',['Sheer and very light','Soft, floaty drape','Slightly rough to the touch'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['tulle','Tulle','',['gowns'],[['Nylon',S],['Polyester',S]],'A light net with tiny six-sided holes. Used for skirts, veils and gown volume.',['Open net of tiny holes','Light; can be stiff or soft','No woven threads'],'syn',[0,'Do not iron. Use steam from a distance']],
 ['lace','Lace','',['gowns'],[['Cotton',N],['Nylon',S],['Polyester',S]],'An open fabric with patterns of holes, often floral. Used for overlays and trims.',['Open floral or patterned holes','Raised design areas','See-through between motifs'],'del',[1,'Low, up to 110 °C, face down on a towel']],
 ['taffeta','Taffeta','',['gowns'],[['Polyester',S],['Silk',N]],'A crisp, smooth fabric that rustles when it moves. Often has a two-tone shimmer.',['Rustles when moved','Two-tone shimmer','Fine crosswise ribs'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['sinamay','Sinamay','',['filipiniana'],[['Abacá',N]],'An open, stiff weave made from abacá fiber. Used for Filipiniana pieces, hats and accents.',['Open, gauzy weave with gaps','Stiff and slightly scratchy','Natural, uneven fibers'],'del',[1,'Low, up to 110 °C, with a press cloth']],
 ['inabel','Inabel','Abel Iloko',['filipiniana'],[['Cotton, handwoven',N]],'A handwoven cotton from Ilocos and La Union, known for bold geometric patterns.',['Woven-in geometric patterns','Thick, sturdy cotton','Slightly uneven handwoven edges'],'cot',[2,'Medium, up to 150 °C, on the reverse side']],
 ['tnalak',"T'nalak",'',['filipiniana'],[['Abacá, handwoven',N]],"A handwoven abacá cloth of the T'boli people, tie-dyed in red, black and natural.",['Red, black and cream patterns','Stiff, glossy abacá','Patterns from tie-dyed threads'],'del',[1,'Avoid ironing. Press lightly through a cloth if needed']],
].map(a=>({id:a[0],name:a[1],aka:a[2],cats:a[3],fibers:a[4].map(x=>({f:x[0],t:x[1]})),desc:a[5],feats:a[6],prof:a[7],iron:a[8]}));
const FB=Object.fromEntries(F.map(f=>[f.id,f]));
const CARE={
 del:{washing:['Hand wash only, in cool water (below 30 °C).','Add a few drops of mild, pH-neutral soap.','Swish gently for 2–3 minutes. Do not rub, twist or wring.','Rinse twice in clean, cool water.'],
      drying:['Roll the garment in a clean towel and press to remove water.','Hang on a padded hanger or lay flat, in the shade.','Keep out of direct sun. Sunlight yellows natural fibers.'],
      ironing:['Iron while the fabric is still slightly damp.','Iron on the reverse side, with a thin cotton press cloth on top.','Press and lift. Do not slide the iron over embroidery.'],
      storage:['Store only when clean and fully dry.','Wrap in acid-free tissue or a clean cotton cloth.','Hang on a padded hanger or roll it. Avoid sharp folds.','Keep away from damp. Add silica gel packs.']},
 syn:{washing:['Turn the garment inside out.','Hand wash, or machine wash on gentle inside a mesh bag.','Use cold water and mild detergent. No bleach.'],
      drying:['Hang to dry in the shade. Synthetics dry fast.','Do not tumble dry on high heat; it can melt or shine the fibers.','Smooth the garment by hand while damp.'],
      ironing:['Iron on the reverse side only.','Use a press cloth so the fabric does not get shiny marks.','Keep the iron moving. High heat can melt synthetic fibers.'],
      storage:['Hang on a wide or padded hanger.','Cover with a breathable cotton garment bag, not plastic.','Leave space in the closet so it does not crease.']},
 cot:{washing:['Wash with similar colours, gentle cycle, 30–40 °C.','For handwoven pieces, hand wash the first few times in case colours run.','Use mild detergent. Avoid bleach on coloured fabric.'],
      drying:['Line dry in the shade.','Take it down while still slightly damp. It irons more easily.','Do not over-dry in a machine; it shrinks.'],
      ironing:['Iron while slightly damp, or use steam.','Iron dark or patterned fabric on the reverse side.','Hang right after ironing.'],
      storage:['Hang shirts on shaped hangers.','Fold linen and handwoven cloth loosely and refold on new lines now and then.','Store in a dry, airy place.']},
 wool:{washing:['Dry cleaning is safest for tailored suits.','To hand wash, use cold water and a wool soap. Do not soak long.','Never wring or rub; wool shrinks and felts.'],
      drying:['Lay flat on a towel, away from heat and sun.','Reshape while damp.','Brush lightly with a clothes brush once dry.'],
      ironing:['Use steam and a damp press cloth.','Press and lift. Do not slide.','Let it cool on the hanger before wearing.'],
      storage:['Hang jackets on wide, shaped hangers.','Rest a suit for a day between wears.','Store with cedar blocks in a breathable bag to keep moths away.']}
};
const STAINS={
 food:{n:'Food & oil',i:'restaurant',s:['Blot (do not rub) with a clean, dry cloth.','For oil, sprinkle cornstarch or baby powder on it. Wait 15 minutes, then brush it off.','Dab with cool water and one drop of mild soap.','Rinse with cool water and air dry.']},
 sweat:{n:'Sweat',i:'water_drop',s:['Mix 1 tablespoon of white vinegar in 1 litre of cool water.','Soak the area for 15 minutes.','Rinse well in clean, cool water.','Do not use hot water. Heat sets the stain.']},
 makeup:{n:'Make-up',i:'brush',s:['Scrape off any extra with a blunt edge.','Dab with mild dish soap on a cotton swab, from the outside in.','Rinse with cool water.']},
 ink:{n:'Ink',i:'ink_pen',s:['Test on a hidden seam first.','Dab with rubbing alcohol on a cotton swab. Blot with a clean cloth.','Repeat until no more ink lifts, then rinse.']}
};
