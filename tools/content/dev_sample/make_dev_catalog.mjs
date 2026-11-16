// Builds assets/content/catalog.json for DEVELOPMENT from the prototype's sample data.
// Everything here is sample content: the researchers write the real catalog (ADR-006).
// Run: node tools/content/dev_sample/make_dev_catalog.mjs
import fs from 'node:fs';
const here = new URL('.', import.meta.url);
const src = fs.readFileSync(new URL('prototype_data.js', here), 'utf8');
const { CATS, F, CARE, STAINS } = new Function(src + '\nreturn {CATS,F,CARE,STAINS};')();
const fid = id => 'FAB-' + id.toUpperCase();
// Placeholder swatches (no researcher photos yet): base colour, accent colour, pattern.
const SW = {
  pina: ['#EFE7D2', '#8C7650', 'plain'], pinaseda: ['#F1E6CF', '#967846', 'sheen'], jusi: ['#F3ECDC', '#D2BE96', 'stripe'],
  organza: ['#E9ECF2', '#5A6482', 'sheen'], cocoon: ['#ECE3CF', '#785F3C', 'crinkle'], wool: ['#3B3D42', '#8A8D94', 'twill'],
  polyvis: ['#1F2A44', '#5B6A8C', 'twill'], cotton: ['#F4F5F2', '#9A9C96', 'plain'], linen: ['#D9CCB2', '#5A4628', 'plain'],
  crepe: ['#26222A', '#6B6470', 'dots'], satin: ['#8D2F4A', '#EFB6C4', 'sheen'], chiffon: ['#F1C9CF', '#E7AAB4', 'sheen'],
  tulle: ['#F3EEF1', '#8C6E82', 'net'], lace: ['#FBF8F2', '#786458', 'lace'], taffeta: ['#2C5F6B', '#A46F8A', 'sheen'],
  sinamay: ['#D8BF8A', '#6E501E', 'net'], inabel: ['#F3ECDC', '#1F2D6B', 'check'], tnalak: ['#3A1F17', '#E7D6B4', 'stripe'],
};
const cite = (sec) => [`SAMPLE-${sec}`];
const fabrics = F.map(f => {
  const p = CARE[f.prof];
  return {
    id: fid(f.id), name: f.name, aka: f.aka ? f.aka.split(', ') : [], categoryIds: f.cats,
    fiberContent: f.fibers.map(x => ({ fiber: x.f, type: x.t, note: '' })),
    description: f.description ?? f.desc, identifyingFeatures: f.feats, images: [],
    swatch: { base: SW[f.id][0], accent: SW[f.id][1], pattern: SW[f.id][2] },
    care: {
      washing: { steps: p.washing, citationIds: cite('washing') },
      drying: { steps: p.drying, citationIds: cite('drying') },
      ironing: { steps: p.ironing, citationIds: cite('ironing'), setting: { dots: f.iron[0], text: f.iron[1] } },
      stainRemoval: {
        steps: [], citationIds: cite('stain'),
        byStain: Object.entries(STAINS).map(([k, s]) => ({ stain: k, steps: s.s, citationIds: cite('stain') })),
      },
      storage: { steps: p.storage, citationIds: cite('storage') },
    },
    reviewedBy: '', reviewedOn: '',
  };
});
const catalog = {
  contentVersion: '0.1.0-sample',
  status: '[PLACEHOLDER] Development sample from the prototype. Not researcher content. Must never ship to TAM.',
  categories: Object.entries(CATS).map(([id, c], i) => ({ id, name: c.name, order: i + 1, description: c.desc, coverFabricId: fid(c.tx) })),
  stainTypes: Object.entries(STAINS).map(([id, s]) => ({ id, name: s.n })),
  fabrics,
  citations: ['washing', 'drying', 'ironing', 'stain', 'storage'].map(s => ({
    id: `SAMPLE-${s}`, apa: `[PLACEHOLDER] Sample citation for the ${s} section. Researchers will add the APA 7 reference.`,
  })),
};
const out = new URL('../../../assets/content/catalog.json', here);
fs.writeFileSync(out, JSON.stringify(catalog, null, 2) + '\n');
console.log(`wrote ${fabrics.length} fabrics, ${catalog.categories.length} categories`);
