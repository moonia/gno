package tokenhub

import (
	"strings"

	"gno.land/p/demo/avl/pager"
	"gno.land/p/demo/grc/grc20"
	"gno.land/p/demo/grc/grc721"
	"gno.land/p/demo/ufmt"
	"gno.land/p/moul/md"
	"gno.land/r/demo/grc20reg"
)

const (
	token = "token" // grc20
	nft   = "nft"   // grc721
	mt    = "mt"    // grc1155
)

func Render(path string) string {
	var out string

	switch {
	case path == "":
		out = renderHome()

	case strings.HasPrefix(path, token):
		out = renderToken(path)

	case strings.HasPrefix(path, nft):
		out = renderNFT(path)

	case strings.HasPrefix(path, mt):
		out = renderMT(path)
	}

	return out
}

func renderHome() string {
	out := md.H1("Token Hub")
	out += md.Paragraph("A central registry for GRC721 NFTs, GRC20 tokens, and GRC1155 multi-tokens on gno.land")

	links := []string{
		"[GRC20 Tokens](/r/matijamarjanovic/tokenhub:tokens)",
		"[GRC721 NFTs](/r/matijamarjanovic/tokenhub:nfts)",
		"[GRC1155 Multi-Tokens](/r/matijamarjanovic/tokenhub:mts)",
	}
	out += md.BulletList(links)

	return out
}

func renderToken(path string) string {
	out := md.H1("GRC20 Tokens")
	var tokenItems []string

	tokenPager := pager.NewPager(grc20reg.GetRegistry(), pageSize, false)
	page := tokenPager.MustGetPageByPath(path)

	for _, item := range page.Items {
		tokenGetter := item.Value.(grc20.TokenGetter)
		token := tokenGetter()
		tokenItems = append(tokenItems, ufmt.Sprintf("%s (%s) [%s]",
			md.Bold(token.GetName()),
			md.InlineCode(token.GetSymbol()),
			md.InlineCode(item.Key)))
	}

	out += renderItemsList(tokenItems, page, "No tokens registered yet")
	out += renderFooter()
	return out
}

func renderNFT(path string) string {
	out := md.H1("GRC721 NFTs")

	var nftItems []string
	nftPager := pager.NewPager(registeredNFTs, pageSize, false)
	page := nftPager.MustGetPageByPath(path)

	for _, item := range page.Items {
		nftGetter := item.Value.(grc721.NFTGetter)
		nft := nftGetter()
		metadata, ok := nft.(grc721.IGRC721CollectionMetadata)
		if !ok {
			continue
		}

		nftItems = append(nftItems, ufmt.Sprintf("%s (%s) [%s]",
			md.Bold(metadata.Name()),
			md.InlineCode(metadata.Symbol()),
			md.InlineCode(item.Key)))
	}

	out += renderItemsList(nftItems, page, "No NFTs registered yet")
	out += renderFooter()
	return out
}

func renderMT(path string) string {
	out := md.H1("GRC1155 Multi-Tokens")
	var mtItems []string

	mtPager := pager.NewPager(registeredMTs, pageSize, false)
	page := mtPager.MustGetPageByPath(path)

	for _, item := range page.Items {
		info := item.Value.(GRC1155TokenInfo)
		mtItems = append(mtItems, ufmt.Sprintf("%s: %s [%s]",
			md.Bold("TokenID"),
			md.InlineCode(info.TokenID),
			md.InlineCode(item.Key)))
	}

	out += renderItemsList(mtItems, page, "No multi-tokens registered yet")
	out += renderFooter()
	return out
}

func renderItemsList(items []string, page *pager.Page, emptyMessage string) string {
	var out string
	if len(items) == 0 {
		out += md.Italic(emptyMessage)
		out += "\n"
		return out
	}

	out += md.BulletList(items)
	out += "\n"
	out += md.HorizontalRule()

	picker := page.Picker(page.Pager.PageQueryParam)
	if picker != "" {
		out += md.Paragraph(picker)
	}

	return out
}

func renderFooter() string {
	out := "\n"
	out += md.Link("Back to home", "/r/matijamarjanovic/tokenhub")
	return out
}
