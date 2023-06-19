# distutils: language = c++

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libc.stdint cimport uint64_t, int64_t
from libcpp cimport bool
from libc.time cimport time_t

cdef extern from "aria2/aria2.h" namespace "aria2":
    cdef struct Session:
        pass
    cdef int libraryInit()
    cdef int libraryDeinit()
    ctypedef uint64_t A2Gid
    ctypedef vector[pair[string, string]] KeyVals

    cdef enum DownloadEvent:
        EVENT_ON_DOWNLOAD_START = 1,
        EVENT_ON_DOWNLOAD_PAUSE,
        EVENT_ON_DOWNLOAD_STOP,
        EVENT_ON_DOWNLOAD_COMPLETE,
        EVENT_ON_DOWNLOAD_ERROR,
        EVENT_ON_BT_DOWNLOAD_COMPLETE

    ctypedef int (*DownloadEventCallback)(Session* session, DownloadEvent event, A2Gid gid, void* userData)

    cdef struct SessionConfig:
        SessionConfig()
        bool keepRunning
        bool useSignalHandler
        DownloadEventCallback downloadEventCallback

        void* userData
    
    cdef Session* sessionNew(const KeyVals& options, const SessionConfig& config)
    cdef int sessionFinal(Session* session)

    cdef enum RUN_MODE:
        RUN_DEFAULT,
        RUN_ONCE

    cdef int run(Session* session, RUN_MODE mode)
    cdef string gidToHex(A2Gid gid)
    cdef A2Gid hexToGid(const string& hex)
    cdef bool isNull(A2Gid)
    # default value is -1 in position
    cdef int addUri(Session* session, A2Gid* gid, const vector[string]& uris, const KeyVals& options, int position)
    cdef int addMetalink(Session* session, vector[A2Gid]* gids, const string& metalinkFile, const KeyVals& options, int position)
    cdef int addTorrent(Session* session, A2Gid* gid, const string& torrentFile, const vector[string]& webSeedUris, const KeyVals& options, int position)
    cdef int addTorrent(Session* session, A2Gid* gid, const string& torrentFile, const KeyVals& options, int position)
    cdef vector[A2Gid] getActiveDownload(Session* session)
    # default value is False in force
    cdef int removeDownload(Session* session, A2Gid gid, bool force)
    cdef int pauseDownload(Session* session, A2Gid gid, bool force)
    cdef int unpauseDownload(Session* session, A2Gid gid)
    cdef int changeOption(Session* session, A2Gid gid, const KeyVals& options)
    cdef const string& getGlobalOption(Session* session, const string& name)
    cdef KeyVals getGlobalOptions(Session* session)
    cdef int changeGlobalOption(Session* session, const KeyVals& options)

    cdef struct GlobalStat:
        int downloadSpeed
        int uploadSpeed
        int numActive
        int numWaiting
        int numStopped

    cdef GlobalStat getGlobalStat(Session* session)

    cdef enum OffsetMode:
        OFFSET_MODE_SET,
        OFFSET_MODE_CUR,
        OFFSET_MODE

    cdef int changePosition(Session* session, A2Gid gid, int pos, OffsetMode how)
    # default value is False in force
    cdef int shutdown(Session* session, bool force)

    cdef enum UriStatus:
        URI_USED,
        URI_WAITING
    
    cdef struct UriData:
        string uri
        UriStatus status

    cdef struct FileData:
        int index
        string path
        int64_t length
        int64_t completedLength
        bool selected
        vector[UriData] uris
    
    cdef enum BtFileMode:
        BT_FILE_MODE_NONE,
        BT_FILE_MODE_SINGLE,
        BT_FILE_MODE_MULTI
    
    cdef struct BtMetaInfoData:
        vector[vector[string]] announceList
        string comment
        time_t creationDate
        BtFileMode mode
        string name
    
    cdef enum DownloadStatus:
        DOWNLOAD_ACTIVE,
        DOWNLOAD_WAITING,
        DOWNLOAD_PAUSED,
        DOWNLOAD_COMPLETE,
        DOWNLOAD_ERROR,
        DOWNLOAD_REMOVED

    cdef cppclass DownloadHandle:
        DownloadStatus getStatus()
        int64_t getTotalLength()
        int64_t getCompletedLength()
        int64_t getUploadLength()
        string getBitfield()
        int getDownloadSpeed()
        int getUploadSpeed()
        const string& getInfoHash()
        size_t getPieceLength()
        int getNumPieces()
        int getConnections()
        int getErrorCode()
        const vector[A2Gid]& getFollowedBy()
        A2Gid getFollowing()
        A2Gid getBelongsTo()
        const string& getDir()
        vector[FileData] getFiles()
        int getNumFiles()
        FileData getFile(int index)
        BtMetaInfoData getBtMetaInfo()
        const string& getOption(const string& name)
        KeyVals getOptions
    
    DownloadHandle* getDownloadHandle(Session* session, A2Gid gid)
    void deleteDownloadHandle(DownloadHandle* dh)