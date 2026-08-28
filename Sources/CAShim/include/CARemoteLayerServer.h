/* CoreAnimation - CARemoteLayerServer.h

   Copyright (c) 2010-2025, Apple Inc.
   All rights reserved. */

#ifdef __OBJC__

#import "CALayer.h"
#import <Foundation/NSObject.h>
#import <mach/mach.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)



@interface CARemoteLayerServer : NSObject
{
}

/* Return the singleton server instance. */

+ (CARemoteLayerServer *)sharedServer;

/* The Mach port that the server listens for new clients on. This
 * should be sent to other processes that want to export layer trees
 * into the server. */

@property(readonly) mach_port_t serverPort;

@end


@interface CALayer (CARemoteLayerServer)

/* Returns a layer that renders the root layer of the client with the given
 * identifier as an extra implicit sublayer. */

+ (CALayer *)layerWithRemoteClientId:(uint32_t)client_id;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
