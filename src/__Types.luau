local DataStoreService = game:GetService("DataStoreService")
export type JSONAcceptable = { JSONAcceptable } | { [string]: JSONAcceptable } | number | string | boolean | buffer

export type Attribute<A, B> = typeof(setmetatable({}, {})) & {
	Name: string,
	Value: B,
	__Subscribed: boolean,
	New: (...any) -> A,
	GetSafe: (self: A) -> JSONAcceptable,
	Set: (self: A, ...any) -> (),
} & A

export type Subscribed<A, B> = Attribute<A, B> & {
	Fire: (...any) -> (),
	Connect: (...any) -> (),
	__signal: {
		Connect: (self: any, listener: (JSONAcceptable) -> ()) -> any,
		Fire: (self: any, ...any) -> (),
	},
} & A

export type Agent = {
	player: Player,
	attributes: { [string]: Attribute<{}, JSONAcceptable> },
	__AddAttribute: (self: Agent, class: Attribute<any, any>, initValue: any, name: string) -> Subscribed<any, any>,
	GetAttribute: (self: Agent, attribute: string) -> Subscribed<any, any>,
	UpdateTable: (self: Agent, attribute: string, callback: (oldValue: {}) -> {}) -> ()
}

export type Cerebral = {
	Agents: { [string]: Agent },
	__New: () -> Cerebral,
	AddAgent: (self: Cerebral, agent: Agent) -> (),
	RemoveAgent: (self: Cerebral, agent: Player) -> (),
}

export type DataStore<A> = {
	DataStoreName: string,

	New: () -> DataStore<A>,
	GetPlayerData: (self: DataStore<A>, player: Player, _kickPlayerOnFail: boolean) -> A,
	UpdatePlayerData: (self: DataStore<A>, player: Player, DataStoreService: A) -> A,
}

export type AvailableDefaultModules = "boolean" | "string" | "number"

return {}
