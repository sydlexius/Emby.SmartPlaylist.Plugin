using System;
using MediaBrowser.Controller.Entities;
using SmartPlaylist;
using System.Linq;
using SmartPlaylist.Domain.Values;
using MediaBrowser.Model.Querying;
using System.Collections.Generic;

public static class Getter
{
    public enum FavoriteLikedEnum
    {
        Favorite,
        Liked,
        None
    }
    private static ListValue[] _officialRatings;
    private static ListValue[] _genre;
    private static Value[] _supportedTypes;
    private static ListValue[] _audioCodecs;
    private static ListValue[] _audioLanguages;
    private static ListValue[] _subtitleLanguages;
    private static ListValue[] _videoCodecs;
    private static Dictionary<FavoriteLikedEnum, ListValue> _favLikedNon = new Dictionary<FavoriteLikedEnum, ListValue>() {
        {FavoriteLikedEnum.Favorite,ListValue.Create("Favorite")},
        {FavoriteLikedEnum.Liked,ListValue.Create("Liked")},
        {FavoriteLikedEnum.None,ListValue.Create("None")},
    };


    public static Dictionary<FavoriteLikedEnum, ListValue> FavoriteLiked => _favLikedNon;

    private static ListValue[] CreateListValues(Func<ListValue[]> funct, string def = "")
    {
        ListValue[] ret = funct.Invoke();
        if (ret.Length == 0)
        {
            ret = new ListValue[] { ListValue.Create(def) };
        }
        return ret;
    }

    public static ListValue[] Genres
    {
        get
        {
            if (_genre == null)
            {
                _genre = CreateListValues(() => Plugin.Instance.LibraryManager.GetGenres(new InternalItemsQuery()).Items.Select(x => x.Item1.ToString())
                        .Distinct().OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray(), "None");
            }
            return _genre;
        }
    }

    public static ListValue[] OfficialRatings
    {
        get
        {
            if (_officialRatings == null)
            {
                try
                {
                    //Bug with 4.8, TODO :Fix when fixed, don't use base items!!!
                    QueryResult<BaseItem> result = Plugin.Instance.LibraryManager.QueryItems(new InternalItemsQuery()
                    {
                        HasOfficialRating = true
                    });

                    _officialRatings = CreateListValues(() => result.Items.Select(x => x.OfficialRating).Distinct()
                                                        .OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray());

                    //_officialRatings = BaseItem.LibraryManager.GetOfficialRatings(new InternalItemsQuery())
                    //                    .Items.OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray();

                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error:" + ex.Message);
                    throw ex;
                }
            }

            return _officialRatings;
        }
    }

    public static Value[] SupportedTypes
    {
        get
        {
            if (_supportedTypes == null)
            {
                _supportedTypes = Const.SupportedItemTypes.OrderBy(x => x.MediaType.Name).Select(s => ListMapValue.Create(s.Description, s.MediaType.Name)).Cast<Value>().ToArray();
            }
            return _supportedTypes;
        }
    }

    public static ListValue[] AudioCodecs
    {
        get
        {
            if (_audioCodecs == null)
            {
                try
                {
                    // Try the new API first (4.9+)
                    _audioCodecs = CreateListValues(() =>
                    {
                        var items = Plugin.Instance.LibraryManager.QueryItems(new InternalItemsQuery
                        {
                            MediaTypes = new[] { MediaBrowser.Model.Entities.MediaType.Audio, MediaBrowser.Model.Entities.MediaType.Video },
                            Recursive = true
                        }).Items;
                        
                        return items
                            .SelectMany(x => x.GetMediaStreams().Where(s => s.Type == MediaBrowser.Model.Entities.MediaStreamType.Audio))
                            .Select(s => s.Codec)
                            .Where(c => !string.IsNullOrEmpty(c))
                            .Distinct()
                            .OrderBy(x => x)
                            .Select(x => ListValue.Create(x))
                            .ToArray();
                    });
                }
                catch
                {
                    // Fallback for older API (4.8.x)
                    try
                    {
                        _audioCodecs = CreateListValues(() => Plugin.Instance.LibraryManager.GetAudioCodecs(new InternalItemsQuery())
                                            .Items.OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray());
                    }
                    catch
                    {
                        _audioCodecs = new ListValue[] { ListValue.Create("") };
                    }
                }
            }
            return _audioCodecs;
        }
    }

    public static ListValue[] AudioLanguages
    {
        get
        {
            if (_audioLanguages == null)
            {
                try
                {
                    // Try the new API first (4.9+)
                    _audioLanguages = CreateListValues(() =>
                    {
                        var items = Plugin.Instance.LibraryManager.QueryItems(new InternalItemsQuery
                        {
                            MediaTypes = new[] { MediaBrowser.Model.Entities.MediaType.Audio, MediaBrowser.Model.Entities.MediaType.Video },
                            Recursive = true
                        }).Items;
                        
                        return items
                            .SelectMany(x => x.GetMediaStreams().Where(s => s.Type == MediaBrowser.Model.Entities.MediaStreamType.Audio))
                            .Select(s => s.Language)
                            .Where(l => !string.IsNullOrEmpty(l))
                            .Distinct()
                            .OrderBy(x => x)
                            .Select(x => ListValue.Create(x))
                            .ToArray();
                    });
                }
                catch
                {
                    // Fallback for older API (4.8.x)
                    try
                    {
                        _audioLanguages = CreateListValues(() => Plugin.Instance.LibraryManager.GetStreamLanguages(new InternalItemsQuery(), MediaBrowser.Model.Entities.MediaStreamType.Audio)
                                            .Items.OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray());
                    }
                    catch
                    {
                        _audioLanguages = new ListValue[] { ListValue.Create("") };
                    }
                }
            }
            return _audioLanguages;
        }
    }

    public static ListValue[] SubtitleLanguages
    {
        get
        {
            if (_subtitleLanguages == null)
            {
                try
                {
                    // Try the new API first (4.9+)
                    _subtitleLanguages = CreateListValues(() =>
                    {
                        var items = Plugin.Instance.LibraryManager.QueryItems(new InternalItemsQuery
                        {
                            MediaTypes = new[] { MediaBrowser.Model.Entities.MediaType.Video },
                            Recursive = true
                        }).Items;
                        
                        return items
                            .SelectMany(x => x.GetMediaStreams().Where(s => s.Type == MediaBrowser.Model.Entities.MediaStreamType.Subtitle))
                            .Select(s => s.Language)
                            .Where(l => !string.IsNullOrEmpty(l))
                            .Distinct()
                            .OrderBy(x => x)
                            .Select(x => ListValue.Create(x))
                            .ToArray();
                    });
                }
                catch
                {
                    // Fallback for older API (4.8.x)
                    try
                    {
                        _subtitleLanguages = CreateListValues(() => Plugin.Instance.LibraryManager.GetStreamLanguages(new InternalItemsQuery(), MediaBrowser.Model.Entities.MediaStreamType.Subtitle)
                            .Items.OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray());
                    }
                    catch
                    {
                        _subtitleLanguages = new ListValue[] { ListValue.Create("") };
                    }
                }
            }
            return _subtitleLanguages;
        }
    }

    public static ListValue[] VideoCodecs
    {
        get
        {
            if (_videoCodecs == null)
            {
                try
                {
                    // Try the new API first (4.9+)
                    _videoCodecs = CreateListValues(() =>
                    {
                        var items = Plugin.Instance.LibraryManager.QueryItems(new InternalItemsQuery
                        {
                            MediaTypes = new[] { MediaBrowser.Model.Entities.MediaType.Video },
                            Recursive = true
                        }).Items;
                        
                        return items
                            .SelectMany(x => x.GetMediaStreams().Where(s => s.Type == MediaBrowser.Model.Entities.MediaStreamType.Video))
                            .Select(s => s.Codec)
                            .Where(c => !string.IsNullOrEmpty(c))
                            .Distinct()
                            .OrderBy(x => x)
                            .Select(x => ListValue.Create(x))
                            .ToArray();
                    });
                }
                catch
                {
                    // Fallback for older API (4.8.x)
                    try
                    {
                        _videoCodecs = CreateListValues(() => Plugin.Instance.LibraryManager.GetVideoCodecs(new InternalItemsQuery())
                                                                .Items.OrderBy(x => x).Select(x => ListValue.Create(x)).ToArray());
                    }
                    catch
                    {
                        _videoCodecs = new ListValue[] { ListValue.Create("") };
                    }
                }
            }
            return _videoCodecs;
        }
    }
}
